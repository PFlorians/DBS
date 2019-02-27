
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
		end;
		else -- otherwise erroneous state
		begin
			print 'Error';
			throw 1, 'Error, user login already exists in database', 1;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE(); --error caught here
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
-- this procedure inserts records to all tables given a specific parameters
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
	set datefirst 1;
	declare @from time;
	declare @day date;
	set datefirst 1; -- needs to be done everywhere
	begin try
		set @from=convert(time, @fromString);
		set @day = convert(date, @dayString, 104);
		if(@ulogin in (select ulogin from attendance.attusr) and
			@shift in (select type from attendance.shift))
		begin 
			set @from = convert(time, @from)
			if(@override = 1)
			begin
				insert into attendance.attendance_record(userLogin, [from], hours_worked_day, [day])
					values (@ulogin, @from, 0, @day);
				if((@absenceType not like '') and (@shift like 'VOLN')) -- means user absent
				begin
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (IDENT_CURRENT('attendance.attendance_record'), @shift);
					insert into attendance.recorded_absence(record_id, [type], absence_length)
						values (IDENT_CURRENT('attendance.attendance_record'), @absenceType, @absenceLength);
				end;
				else if((@absenceType like '') and (@shift like 'VOLN')) -- means user doesn't work
				begin 
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (IDENT_CURRENT('attendance.attendance_record'), @shift);
				end;
				else -- means regular work
				begin
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (IDENT_CURRENT('attendance.attendance_record'), @shift);
				end;
				set @recordId = IDENT_CURRENT('attendance.attendance_record');
			end;
			else
			begin
				set @day = convert(date, getdate(), 101);
				insert into attendance.attendance_record(userLogin, [from], hours_worked_day, [day])
					values (@ulogin, @from, 0, @day);
				if((@absenceType not like '') and (@shift like 'VOLN')) -- means user absent
				begin
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (IDENT_CURRENT('attendance.attendance_record'), @shift);
					insert into attendance.recorded_absence(record_id, [type], absence_length)
						values (IDENT_CURRENT('attendance.attendance_record'), @absenceType, @absenceLength);
				end;
				else if((@absenceType like '') and (@shift like 'VOLN')) -- means user doesn't work
				begin 
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (IDENT_CURRENT('attendance.attendance_record'), @shift);
				end;
				else -- means regular work
				begin
					insert into attendance.recorded_shifts(record_id, shifttype)
						values (IDENT_CURRENT('attendance.attendance_record'), @shift);
				end;
				set @recordId = IDENT_CURRENT('attendance.attendance_record');
			end;
		end;
		else
		begin 
			set @recordId = -1;
			throw 1, 'User or shift not found', 1; -- throw error here
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
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
	set datefirst 1; -- needs to be done everywhere
	begin try
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
			update attendance.attendance_record
			 -- implicit cast to real
			set until = @leaveTime , hours_worked_day = datediff(MINUTE, [from], @leaveTime)/60.0
			where record_id = @recId;
		end;
		else
		begin 
			set @workedHours = (select top 1 (DATEDIFF(minute, [from], @leaveTime)/60.0) - 0.5 
								from attendance.attendance_record where record_id=@recId);
			update attendance.attendance_record
			 -- implicit cast to real
			set until = @leaveTime , hours_worked_day = @workedHours
			where record_id = @recId;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
