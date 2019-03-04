
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
			exec logUserChange @ulogin, @errMsg out;
			insert into attendance.attusr(ulogin, user_typeid, eid, [name], lastname, email)
			values(@ulogin, @user_typeId, @eid, @name, @lastname, @email);
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
					where record_id=@recordId;
			end;
			else
			begin
				insert into attendance.attendance_record(userLogin, [from], hours_worked_day, [day])
					values (@ulogin, @from, 0, @day);
			end;
			if(@errMsg is not null)
			begin
				print @errMsg;
				throw 50111, @errMsg, 50111;
			end;
			else
			begin
				if(@existingRecId = -1)
				begin
					set @recordId = IDENT_CURRENT('attendance.attendance_record');
					exec logRecordChange @recordId, @errMsg out;
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
		else -- real mode nodebug
		begin
			set @day = convert(date, getdate(), 101);
			if(@existingRecId > -1)
			begin
				update attendance.attendance_record
					set userLogin = @ulogin, [from] = @from, until=null, [day] = @day
					where record_id=@recordId;
			end;
			else
			begin
				insert into attendance.attendance_record(userLogin, [from], hours_worked_day, [day])
					values (@ulogin, @from, 0, @day);
			end;
			if(@errMsg is not null)
			begin
				print @errMsg;
				throw 50112, @errMsg, 50112;
			end;
			else
			begin
				if(@existingRecId = -1)
				begin
					set @recordId = IDENT_CURRENT('attendance.attendance_record');
					exec logRecordChange @recordId, @errMsg out;
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
			end;--att recording ends here
		end;
	end;
	else
	begin 
		set @recordId = -1;
		throw 50113, 'User or shift not found', 50113;
	end;
go-- this procedure inserts records to all tables given a specific parameters
-- Required parameters are as follows:
-- user login
-- shift type
-- beginning of work -> end should be handled by updater procedure
-- hours worked should be set to 0 upon initiation -> should be updated on check
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
		if(OBJECT_ID('tempdb..#update_flag') is null)
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
							where ar.record_id=@recordId);
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
		set @recordId = -1; --erroneous state
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
	declare @workedHours real;
	declare @expectedWorkedHours real;
	declare @checkDifference real;
	set datefirst 1;			       
	begin try
		if(OBJECT_ID('tempdb..#update_flag') is null)
		begin
			create table #update_flag(
				flag bit default 0
				);
				insert into #update_flag(flag) values (0);
		end;
	 set @leaveTime = CONVERT(time, @leaveTimeString);
	 set @expectedWorkedHours = (select top 1 ash.planned_hours_work from attendance.attendance_record as ar join
								attendance.recorded_shifts as ars on ars.record_id=ar.record_id
								join attendance.shift as ash on ash.type=ars.shifttype
								where ar.record_id=@recId);
	 set @checkDifference = (select top 1 datediff(minute, ash.start_time, ash.end_time)/60.0 from attendance.attendance_record as ar join
								attendance.recorded_shifts as ars on ars.record_id=ar.record_id
								join attendance.shift as ash on ash.type=ars.shifttype
								where ar.record_id=@recId);
		if(@checkDifference = @expectedWorkedHours)
		begin
			exec logRecordChange @recId, @errMsg out;
			update #update_flag set flag=1;
			update attendance.attendance_record
			 -- implicit cast to real
			set until = @leaveTime , hours_worked_day = datediff(MINUTE, [from], @leaveTime)/60.0
			where record_id = @recId;
			update #update_flag set flag=0;
		end;
		else
		begin 
			set @workedHours = (select top 1 (DATEDIFF(minute, [from], @leaveTime)/60.0) - 0.5 
								from attendance.attendance_record where record_id=@recId);
			exec logRecordChange @recId, @errMsg out;
			update #update_flag set flag=1;
			update attendance.attendance_record
			 -- implicit cast to real
			set until = @leaveTime , hours_worked_day = @workedHours
			where record_id = @recId;
			update #update_flag set flag=0;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		select @errMsg;
	end catch;
go
