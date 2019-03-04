-- customized getter procedures are contained in this file, no write procedure shall be present here
-----------------------------------------------------------------------------------------------------

-- this procedure is a complex view of user's attendance
-- Data read procedures go here
create proc getAttendanceSummaryOfUser
@ulogin varchar(40),
@monthAtt int = 0,
@errMsg varchar(255) output
as
	begin try
		select asu.hours_worked_month [Worked together], asu.bonus_hours_month[Bonus hours], asu.hours_absent_month[Absences together]
			from attendance.attusr au
			join attendance.attendance_record ar on ar.userLogin=au.ulogin
			join attendance.summary asu on asu.record_id=ar.record_id
			where au.ulogin=@ulogin and datepart(month, ar.day) = @monthAtt;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
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

			select ar.[day] [Day], ar.[from] [From], ar.until [Until], ar.hours_worked_day [Worked]
			from attendance.attusr au
			join attendance.attendance_record ar on ar.userLogin=au.ulogin
			where au.ulogin=@ulogin and datepart(month, ar.day) = @monthAtt;

		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
create proc getMonthlyBonusOfUser
@ulogin varchar(40),
@monthAtt int=0, -- cannot initialize by functional expression
@errMsg varchar(255) output
as
	select bon.descr [Bonus], sum(sb.bonus_hours) [Hours together]
			from attendance.attusr au
			join attendance.attendance_record ar on ar.userLogin=au.ulogin
			join attendance.summary asu on asu.record_id=ar.record_id
			join attendance.summary_bonuses sb on sb.summary_id = asu.summary_id
			join attendance.summary_public_holidays sph on sph.summary_id=asu.summary_id
			join attendance.summary_absence sab on sab.summary_id=asu.summary_id
			join attendance.recorded_shifts rs on rs.record_id=ar.record_id
			join attendance.bonus as bon on bon.bonus_id=sb.bonus_id
			where au.ulogin like 'pflorian' and DATEPART(month, ar.day)=2
			group by bon.descr;
