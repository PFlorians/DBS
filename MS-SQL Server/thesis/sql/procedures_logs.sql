-- only logging procedures are stored in this script
-- it is more than likely that these are called within another procedures, thereby the
-- possible exception needs to be detected outside of the scope of these procedures
use attendance_dev
alter proc logUserChange
@ulogin varchar(40),
@errMsg varchar(255) output
as
	set datefirst 1;
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
			set @errMsg = 'Error user not found';
			throw 54012, 'Error user not found', 1;
		end;
	end try
	begin catch
		set @errMsg = Error_message();
		throw 54012, 'Error user not found', 1;
	end catch;
go
alter proc logRecordChange
@recId int,
@changeType smallint,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		if(@recId in (select record_id from attendance.attendance_record))
		begin
			insert into logs.record_change_log(change_timestamp, type_of_change)
				values(convert(datetime2, getdate(), 101), @changeType);
			insert into logs.records_changes(record_id, log_id)
				values(@recId, IDENT_CURRENT('logs.record_change_log'));
		end;
		else
		begin
			set @errMsg = 'Error record not found';
			throw 54001, 'Error record not found', 1;
		end;
	end try
	begin catch
		set @errMsg = error_message();
		throw 54001, 'Error record not found', 1;
	end catch;
go
alter proc summarySnapshot
@summaryId int,
@hours_worked_month real=null,
@bonus_hours_month real=null,
@hours_absent_month real=null,
@hours_worked_inserted real=null,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		insert into logs.summary_state_snapshot(summary_id, [timestamp], hours_worked_month_snap, hours_absent_monh_snap, bonus_hours_month_snap, hours_worked_inserted)
			values(@summaryId, convert(datetime, getdate(), 101), @hours_worked_month, @hours_absent_month,
					@bonus_hours_month, @hours_worked_inserted);
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 54013, @errMsg, 1;
	end catch;
go
