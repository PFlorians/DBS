-- customized getter procedures are contained in this file, no write procedure shall be present here
-----------------------------------------------------------------------------------------------------

-- this procedure is a complex view of user's attendance
-- Data read procedures go here

alter proc getAttendanceSummaryOfUser
@ulogin varchar(40),
@monthAtt int = 0,
@errMsg varchar(255) output
as
	set datefirst 1;
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
alter proc getMonthlyAttendanceOfUser
@ulogin varchar(40),
@monthAtt int=0, -- cannot initialize by functional expression
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		if(@monthAtt = 0)
		begin
			set @monthAtt = DATEPART(month, convert(date, getdate(), 101));

			select ar.[day] [Day], ar.[from] [From], ar.until [Until], ar.hours_worked_day [Worked]
			from attendance.attusr au
			join attendance.attendance_record ar on ar.userLogin=au.ulogin
			where au.ulogin=@ulogin and datepart(month, ar.[day]) = @monthAtt;
		end;
		else
		begin
			select ar.[day] [Day], ar.[from] [From], ar.until [Until], ar.hours_worked_day [Worked]
			from attendance.attusr au
			join attendance.attendance_record ar on ar.userLogin=au.ulogin
			where au.ulogin=@ulogin and datepart(month, ar.[day]) = @monthAtt;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
alter proc getMonthlyBonusOfUser
@ulogin varchar(40),
@monthAtt int=0, -- cannot initialize by functional expression
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		if(@monthAtt = 0)
		begin
			set @monthAtt = datepart(month, convert(date, getdate(), 101));
			select bon.descr [Bonus], sum(sb.bonus_hours) [Hours together]
				from attendance.attusr au
				join attendance.attendance_record ar on ar.userLogin=au.ulogin
				join attendance.summary asu on asu.record_id=ar.record_id
				join attendance.summary_bonuses sb on sb.summary_id = asu.summary_id
				join attendance.bonus as bon on bon.bonus_id=sb.bonus_id
				where au.ulogin=@ulogin and DATEPART(month, ar.day)=@monthAtt
				group by bon.descr;
		end;
		else
		begin
			select bon.descr [Bonus], sum(sb.bonus_hours) [Hours together]
				from attendance.attusr au
				join attendance.attendance_record ar on ar.userLogin=au.ulogin
				join attendance.summary asu on asu.record_id=ar.record_id
				join attendance.summary_bonuses sb on sb.summary_id = asu.summary_id
				join attendance.bonus as bon on bon.bonus_id=sb.bonus_id
				where au.ulogin=@ulogin and DATEPART(month, ar.day)=@monthAtt
				group by bon.descr;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
create proc getUsersPublicHolidaysByMonth
@ulogin varchar(40),
@monthAtt int =0,
@errMsg varchar(255) output
as
	if(@monthAtt = 0)
	begin
		set @monthAtt = datepart(month, convert(date, getdate(), 101));
		select ph.[date] as [date], sph. from attendance.attusr atu
			join attendance.attendance_record ar on ar.userLogin=atu.ulogin
			join attendance.summary asu on asu.record_id=ar.record_id
			join attendance.summary_public_holidays sph on sph.summary_id=asu.summary_id
			join attendance.public_holidays ph on ph.id=sph.public_holiday_id
			where atu.ulogin = @ulogin
			group by
	end;
	else
	begin

	end;
