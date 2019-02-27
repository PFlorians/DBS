-- only logging procedures are stored in this script
alter proc logUserChange
@ulogin varchar(40),
@errMsg varchar(255) output
as
	set datefirst 1; -- needs to be done everywhere
	begin try
		if(@ulogin in (select ulogin from attendance.attusr))
		begin
			insert into logs.user_change_log(log_time)
				values(convert(datetime2, GETDATE(), 101));
			insert into logs.user_changes(log_id, userLogin)
				values(IDENT_CURRENT('logs.user_change_log'), @ulogin);
		end;
		else
		begin
			print 'Error user not found';
			throw 1000, 'Error user not found - log user change error', 1000;
		end;
	end try
	begin catch
		set @errMsg = Error_message();
	end catch;
go
alter proc logRecordChange
@recId int,
@errMsg varchar(255) output
as
	set datefirst 1; -- needs to be done everywhere
	begin try
		if(@recId in (select record_id from attendance.attendance_record))
		begin
			insert into logs.record_change_log(change_timestamp)
				values(convert(datetime2, getdate(), 101));
			insert into logs.records_changes(record_id, log_id)
				values(@recId, IDENT_CURRENT('logs.record_change_log'));
		end;
		else
		begin 
			print 'Error record not found - log record change error';
			throw 1001, 'Error record not found - log record change error', 1001;
		end;
	end try
	begin catch
		set @errMsg = error_message();
	end catch;
go