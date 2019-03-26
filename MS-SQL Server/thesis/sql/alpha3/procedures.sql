use attendance_dev
-- if user doesn't exists then create one
use master
use attendance_dev
create proc init_user
@ulogin varchar(40), -- needs to be unique since this is a primary key identifier
@user_typeId int,
@eid varchar(20),
@name varchar(50),
@lastname varchar(50),
@email varchar(100),
@errMsg varchar(255) output
as
	begin try
		if(not exists(select 1 from attendance.attusr where ulogin=@ulogin)) -- proceed with creation
		begin
			insert into attendance.attusr(ulogin, user_typeid, eid, [name], lastname, email)
			values(@ulogin, @user_typeId, @eid, @name, @lastname, @email);
			exec logUserChange @ulogin, @errMsg out;
		end;
		else -- otherwise erroneous state
		begin
			print 'Error';
			throw 50100, 'Error, user login already exists in database', 1;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE(); --error caught here
		throw 50100, @errMsg, 1;
	end catch;
go
-- check if user exists
alter proc userExists
@ulogin varchar(40),
@var bit output,
@errMsg varchar(255) output
as
	set @var = 0;--default not exists
	begin try
		if(exists(select 1 from attendance.attusr where ulogin=@ulogin))
		begin
			set @var = 1;
		end;
		else
		begin
			set @var = 0;
		end;
		select @var as [var];
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		select xact_state();
	end catch;
go
alter proc attRecInsertionSubroutine -- this must be called within try catch block
@ulogin varchar(40),
@fromString varchar(40),
@shift varchar(8),
@absenceType varchar(4) = '',
@absenceLength real = 0,
@dayString varchar(40) = null, -- default
@existingRecId int = -1,
@errMsg varchar(255) output,
@recordId int output
as
	declare @from time;
	declare @day date;
	set datefirst 1;
	set @from=convert(time, @fromString);
	set @day = convert(date, @dayString, 104);
	if(@ulogin in (select ulogin from attendance.attusr) and
		@shift in (select type from attendance.shift))
	begin
		set @from = convert(time, @from)
		if(@existingRecId > -1)
		begin
			update attendance.attendance_record
				set userLogin = @ulogin, [from] = @from, until=null, [day] = @day
				where record_id=@existingRecId;
			exec logRecordChange @existingRecId, 2, @errMsg out;--log this change as update
			if(@errMsg is not null)
			begin
				;
				throw 50122, @errMsg, 1;
			end;
			-- update dependent entities
			if((@absenceType not like '') and (@shift like 'VOLN') and (@from=convert(time, '00:00:00'))) -- means user absent
			begin
				--update instead
				update attendance.recorded_shifts
					set shifttype=@shift
					where record_id=@existingRecId;
				/*update attendance.summary_absence
					set absence_type=@absenceType, day_of_absence=@day, hours_absent=@absenceLength
					where record_id=@existingRecId;*/
				/*update attendance.recorded_absence
					set [type]=@absenceType, absence_length=@absenceLength
					where record_id=@existingRecId;*/
			end;
			else if((@absenceType like '') and (@shift like 'VOLN') and (@from=convert(time, '00:00:00'))) -- means user doesn't work
			begin
				update attendance.recorded_shifts
					set shifttype=@shift
					where record_id=@existingRecId;
			end;
			else -- means regular work
			begin
				update attendance.recorded_shifts
					set shifttype = @shift
					where record_id=@existingRecId;
			end;
		end;
		else -- need to insert, no update
		begin
			insert into attendance.attendance_record(userLogin, [from], hours_worked_day, [day])
				values (@ulogin, @from, 0, @day);
			set @recordId = IDENT_CURRENT('attendance.attendance_record');
			exec logRecordChange @recordId, 1, @errMsg out;--log change
			if(@errMsg is not null)
			begin
				;
				throw 50122, @errMsg, 1;
			end;
			-- insert into dependent entities
			if((@absenceType not like '') and (@shift like 'VOLN') and (@from=convert(time, '00:00:00'))) -- means user absent
			begin
				insert into attendance.recorded_shifts(record_id, shifttype)
					values (@recordId, @shift);
				insert into attendance.summary_absence(absence_type, day_of_absence, hours_absent, record_id)
					values(@absenceType, @day, @absenceLength, @recordId);
				/*insert into attendance.recorded_absence(record_id, [type], absence_length)
					values (@recordId, @absenceType, @absenceLength);*/
			end;
			else if((@absenceType like '') and (@shift like 'VOLN') and (@from=convert(time, '00:00:00'))) -- means user doesn't work
			begin
				insert into attendance.recorded_shifts(record_id, shifttype)
					values (@recordId, @shift);
			end;
			else -- means regular work
			begin
				insert into attendance.recorded_shifts(record_id, shifttype)
					values (@recordId, @shift);
			end;
		end;
	end;
	else
	begin
		set @recordId = -1;
		set @errMsg = ERROR_MESSAGE();
		throw 50113, 'User or shift not found', 1;
		select XACT_STATE();
	end;
go
alter proc newAttendanceRecord
@ulogin varchar(40),
@fromString varchar(40),
@shift varchar(8),
@absenceType varchar(4) = '',
@absenceLength real = 0,
@dayString varchar(40) = null, -- default
@errMsg varchar(255) output,
@recordId int output
as
	declare @from time;
	declare @day date;
	set datefirst 1;
	begin try
		if(OBJECT_ID('tempdb..#update_flag') is null) --indicates whether an update is to be done
		begin
			create table #update_flag(
				flag bit default 0
				);
				insert into #update_flag(flag) values (0);
		end;
		set @from=convert(time, @fromString);
		set @day = convert(date, @dayString, 104);
		if(@day in (select [day] from attendance.attendance_record where userLogin=@ulogin)) -- someone beeps two times in succession
		begin
			declare @logTime time;
			-- we need to check timestamp in log to probe for changes
			set @recordId = (select top 1 record_id from attendance.attendance_record where [day]=@day and userLogin=@ulogin);
			set @logTime = (select top 1 convert(time, rcl.change_timestamp, 101) from logs.record_change_log rcl
							join logs.records_changes as rc on rc.log_id=rcl.log_id
							join attendance.attendance_record as ar on ar.record_id=rc.record_id
							where ar.record_id=@recordId and (type_of_change = 1)); -- ignore if update for security reasons
			if(abs(datediff(second, convert(time, getdate(), 101), @logTime))<=180)--difference less than 3 minutes
			begin --rewrite, otherwise error
				exec attRecInsertionSubroutine @ulogin, @fromString, @shift, @absenceType, @absenceLength, @dayString, @recordId, @errMsg out, @recordId out;
			end;
			else
			begin
				set @recordId = -1; --error
				throw 50111, 'Error, cannot rewrite this arrival time', 1;
			end;
		end;
		else -- regular procedure
		begin
			exec attRecInsertionSubroutine @ulogin, @fromString, @shift, @absenceType, @absenceLength, @dayString, -1, @errMsg out, @recordId out;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		select XACT_STATE();
		set @recordId = -1; --erroneous state
		throw 50112, @errMsg, 1;
	end catch;
go
--updates attendance record in a standard manner -> that is automatic - user changes are done
-- in a different manner
-- should be called after new record creation was performed - user leaving workplace
-- see associated insert trigger checking if the end of month is reached
-- this procedure has to write into summary bonuses according to recorded shifts and shift type
--update Att record decides whether this is a departure kind of update as in user leaving(new record ought to be created beforehand)
-- other case is if a new record was created, no departure is done so far and newly created needs to be altered
-- third case is when record exists normally and anything about it needs to changed
create proc updateAttRecord
@recId int,
@timeStringArrive varchar(40) = null,
@timeStringDepart varchar(40) = null,
@shift varchar(8) = '',
@absenceType varchar(4)='',
@absenceLength int = 0,
@typeOfUpdate smallint = 0,
@errMsg varchar(255) output
as
	begin try
		if(@typeOfUpdate = 0) -- regular departure
		begin
			if(@timeStringDepart is not null)
			begin
				exec updateAttRecordDeparture @recId, @timeStringDepart, 0, @errMsg = @errMsg;
			end;
			else
			begin
				set @errMsg = 'Error departure time cannot be empty';
				throw 55550, @errMsg, 1;
			end;
		end;
		else if(@typeOfUpdate = 1) -- alteration of both
		begin
			if(@timeStringArrive is not null or @timeStringDepart is not null)
			begin
				exec recordAlteration @recId, @timeStringArrive, @timeStringDepart, @shift, @absenceType, @absenceLength, @errMsg = @errMsg;
			end;
			else
			begin
				set @errMsg = 'Error one of the variables - time of Arrival or Departure needs to be non null';
				throw 55551, @errMsg, 1;
			end;
		end;
		else --others not defined
		begin
			set @errMsg = 'Error, updating subroutine option not defined';
			throw 55555, @errMsg, 1;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 55556, @errMsg, 1;
	end catch;
go
create proc recordAlteration -- change existing record
@recId int,
@timeStringArrive varchar(40) = null,
@timeStringDepart varchar(40) = null,
@shift varchar(8) = '',
@absenceType varchar(4)='',
@absenceLength int = 0,
@errMsg varchar(255) output
as
	declare @day date;
	declare @dayString varchar(40)
	declare @ulogin varchar(40);
	
	set datefirst 1;
	begin try
		if((select top 1 record_id from attendance.attendance_record where record_id=@recId) is not null)
		begin
			if(OBJECT_ID('tempdb..#update_flag') is null) -- indicates whether an update is to be done
			begin
				create table #update_flag(
					flag bit default 0
					);
					insert into #update_flag(flag) values (0);
			end;
			-- set variables
			set @ulogin = (select top 1 userLogin from attendance.attendance_record where record_id = @recId);
			if(@shift like '' or @shift is null) -- otherwise the shift type was given via parameter
			begin
				set @shift = (select top 1 ash.[type] from attendance.attendance_record as ar join
											attendance.recorded_shifts ars on ars.record_id=ar.record_id join
											attendance.shift as ash on ash.[type]=ars.shifttype
											where ar.record_id=@recId);
			end;
			set @day = (select top 1 ar.[day] from attendance.attendance_record ar where ar.record_id=@recId);
			set @dayString = convert(varchar, @day, 104);--because of definition of subroutine

			if(@timeStringArrive is not null and @timeStringDepart is null)--if given only arrival then update only that
			begin --rewrite, otherwise error
				exec attRecInsertionSubroutine @ulogin, @timeStringArrive, @shift, @absenceType, @absenceLength, @dayString, @recId, @errMsg out, @recId out;
				if(@errMsg is not null)
				begin
					; throw 55500, @errMsg, 1; 
				end;
			end;
			else if(@timeStringArrive is null and @timeStringDepart is not null)
			begin
				exec updateAttRecordDeparture @recId, @timeStringDepart, 1, @errMsg = @errMsg; -- force the update
				if(@errMsg is not null)
				begin
					; throw 55501, @errMsg, 1;
				end;
			end;
			else -- if we have both then invoke both methods
			begin
				exec attRecInsertionSubroutine @ulogin, @timeStringArrive, @shift, @absenceType, @absenceLength, @dayString, @recId, @errMsg out, @recId out;
				if(@errMsg is not null)
				begin
					; throw 55503, @errMsg, 1;
				end;
				exec updateAttRecordDeparture @recId, @timeStringDepart, 1, @errMsg = @errMsg; -- force the update
				if(@errMsg is not null)
				begin
				; throw 55502, @errMsg, 1;
				end;
			end;
		end;
		else
		begin
			set @errMsg = 'Error, record number: '+ convert(varchar, @recId)+ ' not found';
			; throw 55504, @errMsg, 1;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 55505, @errMsg, 1;
	end catch;
go
alter proc updateAttRecordDeparture
@recId int,
@leaveTimeString varchar(40),
@forceUpdate bit = 0, -- if this is up then it will force to update the record without the 3 minutes update once rule
@errMsg varchar(255) output
as
	declare @leaveTime time;
	declare @arriveTime time;
	declare @workedHours real;
	declare @expectedWorkedHours real;
	declare @checkDifference real;
	declare @day date;
	declare @arriveDtm datetime;
	declare @leaveDtm datetime;
	declare @logTime time;
	declare @shift varchar(8);
	declare @sumOfBonuses real;
	declare @sumOfAbsences real;
	declare @summaryId int;
	declare @summaryMonth int;
	declare @ulogin varchar(40);

	set datefirst 1;
	begin try
	if((select top 1 record_id from attendance.attendance_record where record_id=@recId) is not null)
	begin
			if(OBJECT_ID('tempdb..#update_flag') is null) -- indicates whether an update is to be done
			begin
				create table #update_flag(
					flag bit default 0
					);
					insert into #update_flag(flag) values (0);
			end;
		 set @leaveTime = CONVERT(time, @leaveTimeString);
		 set @arriveTime = (select top 1 ar.[from] from attendance.attendance_record ar where ar.record_id=@recId);
		 set @expectedWorkedHours = (select top 1 ash.planned_hours_work from attendance.attendance_record as ar join
									attendance.recorded_shifts as ars on ars.record_id=ar.record_id
									join attendance.shift as ash on ash.type=ars.shifttype
									where ar.record_id=@recId);
		 set @checkDifference = (select top 1  (case
									when ash.[type] like 'N%'
										then datediff(hour, convert(datetime, ash.start_time), dateadd(day, 1, convert(datetime, ash.end_time)))
										else datediff(minute, ash.start_time, ash.end_time)/60.0
									end)
									from attendance.attendance_record as ar join
									attendance.recorded_shifts as ars on ars.record_id=ar.record_id
									join attendance.shift as ash on ash.type=ars.shifttype
									where ar.record_id=@recId);
		set @shift = (select top 1 ash.[type] from attendance.attendance_record as ar join
										attendance.recorded_shifts ars on ars.record_id=ar.record_id join
										attendance.shift as ash on ash.type=ars.shifttype
										where ar.record_id=@recId);
		set @day = (select top 1 ar.[day] from attendance.attendance_record ar where ar.record_id=@recId);
		set @ulogin = (select top 1 userLogin from attendance.attendance_record where record_id = @recId);
		set @summaryMonth = (select top 1 DATEPART(month, [day]) from attendance.attendance_record where record_id=@recId);

		set @summaryId = (select top 1 summary_id from attendance.summary where record_id=(
						select top 1 record_id from attendance.attendance_record where datepart(month, [day]) = @summaryMonth 
							and userLogin=@ulogin order by record_id asc) 
						);
		-- very specific for public holiday only
		if(@day in (select [date] from attendance.public_holidays))
		begin
			set @expectedWorkedHours = 0.0;
			set @checkDifference = 0.0;
		end;
		-- this could have been a night shift, we need to check that
			if((cast(convert(datetime, @leaveTime) as float) - cast(convert(datetime, @arriveTime) as float))<0.0)
			begin
				-- if I am here it has been confirmed
				set @arriveDtm = convert(datetime, @day) + convert(datetime, @arriveTime);
				set @leaveDtm = convert(datetime, dateadd(day, 1, @day)) + convert(datetime, @leaveTime);
				set @workedHours = (abs(datediff(second, @leaveDtm, @arriveDtm))/60.0)/60.0;
				if(@checkDifference <> @expectedWorkedHours) -- necessary in case we need to subtract lunch break
				begin
					set @workedHours = @workedHours - 0.5;
				end;-- could be a that this is some kind of work during weekend or public holiday
				else
				begin
					if(@checkDifference = 0 and @expectedWorkedHours = 0)
					begin
						if(@shift like 'VOLN' and @workedHours >= 4.5 and (@day not in (select [date] from attendance.public_holidays)))
						begin
							set @workedHours = @workedHours - 0.5;
						end;
						else if(@shift not like 'VOLN' and @workedHours >= 4.5 and (@day in (select [date] from attendance.public_holidays)))
						begin
							set @workedHours = @workedHours - 0.5;
						end;
					end;
				end;
			end;
			else
			begin
				if(@checkDifference <> @expectedWorkedHours) -- necessary in case we need to subtract lunch break
				begin
					set @workedHours = (select top 1 (DATEDIFF(minute, [from], @leaveTime)/60.0) - 0.5
									from attendance.attendance_record where record_id=@recId);
				end;-- could be a that this is some kind of work during weekend or public holiday
				else
				begin
					set @workedHours = (select top 1 (DATEDIFF(minute, [from], @leaveTime)/60.0)
									from attendance.attendance_record where record_id=@recId);
					if(@checkDifference = 0 and @expectedWorkedHours = 0)
					begin
						if(@shift like 'VOLN' and @workedHours >= 4.5 and (@day not in (select [date] from attendance.public_holidays)))
						begin
							set @workedHours = @workedHours - 0.5;
						end;
						else if(@shift not like 'VOLN' and @workedHours >= 4.5 and (@day in (select [date] from attendance.public_holidays)))
						begin
							set @workedHours = @workedHours - 0.5;
						end;
					end;
				end;
			end;
			-- update starts here
			-- check if last update less than 3 minutes ago
			-- this applies only under normal circumstances, in case those are not met then a forcible update will take place
			set @logTime = (select top 1 convert(time, rcl.change_timestamp, 101) from logs.record_change_log rcl
									join logs.records_changes as rc on rc.log_id=rcl.log_id
									join attendance.attendance_record as ar on ar.record_id=rc.record_id
									where ar.record_id=@recId and (type_of_change = 3));
			if(abs(datediff(second, convert(time, getdate(), 101), @logTime))<=180 and @forceUpdate = 0)
			begin
				update #update_flag set flag=0;
			end;
			else if(((abs(datediff(second, convert(time, getdate(), 101), @logTime))<=180) or 
						(abs(datediff(second, convert(time, getdate(), 101), @logTime))>180)) and @forceUpdate=1) -- time doesn't matter update will be forced
			begin
				update #update_flag set flag=0;
				if(OBJECT_ID('tempdb..#force_update_flag') is null) -- indicates whether an update is to be done
				begin
					create table #force_update_flag(
						flag bit default 0
						);
						insert into #force_update_flag(flag) values (1);
				end;
				else
				begin
					update #force_update_flag set flag=1;
				end;
			end;
			else
			begin
				update #update_flag set flag=1;
			end;
			-- cleanup if force update
			if(@forceUpdate = 1)
			begin
				if((select top 1 record_id from attendance.summary_bonuses where record_id=@recId) is not null)
				begin
					set @sumOfBonuses = (select sum(bonus_hours) from attendance.summary_bonuses where record_id=@recId);
					delete from attendance.summary_bonuses where record_id=@recId;
					update attendance.summary
						set bonus_hours_month = bonus_hours_month -	@sumOfBonuses
						where summary_id=@summaryId;
				end;
				if((select top 1 record_id from attendance.summary_absence where record_id=@recId) is not null)
				begin
					set @sumOfAbsences = (select sum(hours_absent) from attendance.summary_absence where record_id=@recId);
					delete from attendance.summary_absences where record_id=@recId;
					update attendance.summary
						set hours_absent_month = hours_absent_month - @sumOfAbsences
						where summary_id=@summaryId;
				end;
				if((select top 1 record_id from attendance.attendance_record where record_id=@recId) is not null)
				begin
					update attendance.summary
						set hours_worked_month = hours_worked_month - 
												(select top 1 hours_worked_day from attendance.attendance_record 
												where record_id=@recId)
						where summary_id=@summaryId;
				end;
			end;
			update attendance.attendance_record
			 -- implicit cast to real
			set until = @leaveTime , hours_worked_day = @workedHours
			where record_id = @recId;
			if((select top 1 flag from #update_flag) = 0)
			begin
				exec logRecordChange @recId, 4, @errMsg out;--log this as an update of departure
			end;
			else
			begin
				exec logRecordChange @recId, 3, @errMsg out;--log this as an insertion update(standard)
			end;
			if(@errMsg is not null)
			begin
				;
				throw 50122, @errMsg, 1;
			end;
			update #update_flag set flag=0;
		end;
		else
		begin
			set @errMsg = 'Error, record number: '+ convert(varchar, @recId)+ ' not found';
			; throw 50133, @errMsg, 1;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		select XACT_STATE();
	end catch;
go
