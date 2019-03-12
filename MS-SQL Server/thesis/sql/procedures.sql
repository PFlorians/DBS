
-- if user doesn't exists then create one
alter proc init_user
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
@override bit = 0, -- TESTING INPUT
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
		if(@override = 1)
		begin
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
				if((@absenceType not like '') and (@shift like 'VOLN')) -- means user absent
				begin
					--update instead
					update attendance.recorded_shifts
						set shifttype=@shift
						where record_id=@existingRecId;
					update attendance.recorded_absence
						set [type]=@absenceType, absence_length=@absenceLength
						where record_id=@existingRecId;
				end;
				else if((@absenceType like '') and (@shift like 'VOLN')) -- means user doesn't work
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
				if((@absenceType not like '') and (@shift like 'VOLN')) -- means user absent
				begin
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (@recordId, @shift);
					insert into attendance.recorded_absence(record_id, [type], absence_length)
						values (@recordId, @absenceType, @absenceLength);
				end;
				else if((@absenceType like '') and (@shift like 'VOLN')) -- means user doesn't work
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
		else -- real mode nodebug
		begin
			set @day = convert(date, getdate(), 101);
			if(@existingRecId > -1)
			begin
				update attendance.attendance_record
					set userLogin = @ulogin, [from] = @from, until=null, [day] = @day
					where record_id=@existingRecId;
				exec logRecordChange @existingRecId, 2, @errMsg out;--log this as update
				if(@errMsg is not null)
				begin
					;
					throw 50122, @errMsg, 1;
				end;
				-- update dependent entities
				if((@absenceType not like '') and (@shift like 'VOLN')) -- means user absent
				begin
					--update instead
					update attendance.recorded_shifts
						set shifttype=@shift
						where record_id=@existingRecId;
					update attendance.recorded_absence
						set [type]=@absenceType, absence_length=@absenceLength
						where record_id=@existingRecId;
				end;
				else if((@absenceType like '') and (@shift like 'VOLN')) -- means user doesn't work
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
				if((@absenceType not like '') and (@shift like 'VOLN')) -- means user absent
				begin
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (@recordId, @shift);
					insert into attendance.recorded_absence(record_id, [type], absence_length)
						values (@recordId, @absenceType, @absenceLength);
				end;
				else if((@absenceType like '') and (@shift like 'VOLN')) -- means user doesn't work
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
	end;
	else
	begin
		set @recordId = -1;
		set @errMsg = ERROR_MESSAGE();
		throw 50113, 'User or shift not found', 50113;
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
@override bit = 0, -- TESTING INPUT
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
		if(@day in (select [day] from attendance.attendance_record)) -- someone beeps two times in succession
		begin
			declare @logTime time;
			-- we need to check timestamp in log to probe for changes
			set @recordId = (select top 1 record_id from attendance.attendance_record where [day]=@day);
			set @logTime = (select top 1 convert(time, rcl.change_timestamp, 101) from logs.record_change_log rcl
							join logs.records_changes as rc on rc.log_id=rcl.log_id
							join attendance.attendance_record as ar on ar.record_id=rc.record_id
							where ar.record_id=@recordId and (type_of_change = 1)); -- ignore if update for security reasons
			if(abs(datediff(second, convert(time, getdate(), 101), @logTime))<=180)--difference less than 3 minutes
			begin --rewrite, otherwise error
				exec attRecInsertionSubroutine @ulogin, @fromString, @shift, @absenceType, @absenceLength, @dayString, @override, @recordId, @errMsg out, @recordId out;
			end;
			else
			begin
				set @recordId = -1; --error
				throw 50111, 'Error, cannot rewrite this arrival time', 1;
			end;
		end;
		else -- regular procedure
		begin
			exec attRecInsertionSubroutine @ulogin, @fromString, @shift, @absenceType, @absenceLength, @dayString, @override, -1, @errMsg out, @recordId out;
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
alter proc updateAttRecord
@recId int,
@leaveTimeString varchar(40),
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

	set datefirst 1;
	begin try
	if((select top 1 record_id from attendance.attendance_record where record_id=@recId) is not null)
	begin
			if(OBJECT_ID('tempdb..#update_flag') is null) -- indicates whether an update is to be don
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
				else if((@checkDifference = 0) and (@expectedWorkedHours = 0) and (@shift like 'VOLN') and (@workedHours >= 4.5))
				begin
					set @workedHours = @workedHours - 0.5;
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
						if(@shift like 'VOLN' and @workedHours >= 4.5)
						begin
							set @workedHours = @workedHours - 0.5;
						end;
					end;
				end;
			end;
			--check if last update less than 3 minutes ago
			set @logTime = (select top 1 convert(time, rcl.change_timestamp, 101) from logs.record_change_log rcl
									join logs.records_changes as rc on rc.log_id=rcl.log_id
									join attendance.attendance_record as ar on ar.record_id=rc.record_id
									where ar.record_id=@recId and (type_of_change = 3));
			if(abs(datediff(second, convert(time, getdate(), 101), @logTime))<=180)
			begin
				update #update_flag set flag=0;
			end;
			else
			begin
				update #update_flag set flag=1;
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
