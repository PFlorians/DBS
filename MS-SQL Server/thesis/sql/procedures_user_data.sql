-- customized getter procedures are contained in this file, no write procedure shall be present here
-----------------------------------------------------------------------------------------------------

-- this procedure is a complex view of user's attendance
create proc getMonthlyAttendanceOfUser
@ulogin varchar(40),
@monthAtt int=0, -- cannot initialize by functional expression
@errMsg varchar(255) output
as
	begin try
		if(@monthAtt = 0)
		begin
			set @monthAtt = DATEPART(month, convert(date, getdate(), 101));
		select * from attendance.attusr au
		join attendance.attendance_record ar on ar.userLogin=au.ulogin
		join attendance.summary asu on asu.record_id=ar.record_id
		join attendance.summary_bonuses sb on sb.summary_id = asu.summary_id
		join attendance.summary_public_holidays sph on sph.summary_id=asu.summary_id
		join attendance.summary_absence sab on sab.summary_id=asu.summary_id
		join attendance.recorded_shifts rs on rs.record_id=ar.record_id
		where au.ulogin=@ulogin;

	end try
		end;
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go