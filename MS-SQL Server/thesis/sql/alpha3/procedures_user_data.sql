-- customized getter procedures are contained in this file, no write procedure shall be present here
-----------------------------------------------------------------------------------------------------

-- this procedure is a complex view of user's attendance
-- Data read procedures go here
use master
use attendance_dev

alter proc getMonthlyAttendanceOfUser
@ulogin varchar(40),
@monthAtt int = 0,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		if(@monthAtt = 0)
		begin
			set @monthAtt = DATEPART(month, convert(date, getdate(), 101));
			select ar.[day] [day], ar.[from] [from], ar.until [until], ar.hours_worked_day [hours_worked_day], ars.shifttype [shifttype]
				from attendance.attendance_record ar
				join attendance.recorded_shifts ars on ars.record_id=ar.record_id
				where DATEPART(month, [day]) = @monthAtt and userLogin = @ulogin
				order by [day];
		end;
		else
		begin
			select ar.[day] [day], ar.[from] [from], ar.until [until], ar.hours_worked_day [hours_worked_day], ars.shifttype [shifttype]
				from attendance.attendance_record ar
				join attendance.recorded_shifts ars on ars.record_id=ar.record_id
				where DATEPART(month, [day]) = @monthAtt and userLogin = @ulogin
				order by [day];
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
begin tran t1
declare @errMsg varchar(255);
exec getMonthlyAttendanceOfUser 'pflorian', 2, @errMsg out;
rollback tran t1
go
create proc getMonthlyBonusesOfUser
@ulogin varchar(40),
@monthAtt int = 0,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		if(@monthAtt = 0)
		begin
			set @monthAtt = DATEPART(month, convert(date, getdate(), 101));
			select asb.[day] [day], asb.bonus_id [id], asb.bonus_hours [bonus_hours], ab.descr [descr]
			from attendance.attendance_record ar 
			join attendance.summary_bonuses asb on asb.record_id=ar.record_id
			join attendance.bonus ab on ab.bonus_id = asb.bonus_id
			where ar.userLogin = @ulogin and DATEPART(month, ar.[day]) = @monthAtt
			order by asb.[day] asc;
		end;
		else
		begin
			select asb.[day] [day], asb.bonus_id [id], asb.bonus_hours [bonus_hours], ab.descr [descr]
			from attendance.attendance_record ar 
			join attendance.summary_bonuses asb on asb.record_id=ar.record_id
			join attendance.bonus ab on ab.bonus_id = asb.bonus_id
			where ar.userLogin = @ulogin and DATEPART(month, ar.[day]) = @monthAtt
			order by asb.[day] asc;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
--get and return monthly absences
create proc getMonthlyAbsencesOfUser
@ulogin varchar(40),
@monthAtt int = 0,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		if(@monthAtt = 0)
		begin
			set @monthAtt = DATEPART(month, convert(date, getdate(), 101));
			select asa.day_of_absence [day_of_absence], asa.absence_type [absence_type], asa.hours_absent [hours_absent],
			aa.descr [descr]
			from attendance.attendance_record ar 
			join attendance.summary_absence asa on asa.record_id=ar.record_id
			join attendance.absence aa on aa.[type] = asa.[absence_type]
			where ar.userLogin = @ulogin and DATEPART(month, ar.[day]) = @monthAtt;
		end;
		else
		begin
			select asa.day_of_absence [day_of_absence], asa.absence_type [absence_type], asa.hours_absent [hours_absent],
			aa.descr [descr]
			from attendance.attendance_record ar 
			join attendance.summary_absence asa on asa.record_id=ar.record_id
			join attendance.absence aa on aa.[type] = asa.[absence_type]
			where ar.userLogin = @ulogin and DATEPART(month, ar.[day]) = @monthAtt;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
begin tran t2
	declare @errMsg varchar(255);
	exec getMonthlyBonusesOfUser 'pflorian', 5, @errMsg out;
	exec getMonthlyAbsencesOfUser 'pflorian', 2, @errMsg out;
rollback tran t2
go
alter proc getMonthlySummaryOfUser
@ulogin varchar(40),
@monthAtt int = 0,
@errMsg varchar(255) output
as
	declare @summaryId int;
	set @summaryId=(select top 1 asu.summary_id from attendance.attusr as au
			join attendance.attendance_record as ar on ar.userLogin = au.ulogin
			join attendance.summary as asu on asu.record_id=ar.record_id
			where ar.userLogin = @ulogin and (@monthAtt = MONTH(ar.[day]))
			order by ar.record_id asc);
	begin try
		if(@summaryId is not null)
		begin
			select hours_worked_month [worked], bonus_hours_month [bonus], hours_absent_month [absent]
			from attendance.summary ass
			where summary_id=@summaryId;
		end;
		else
		begin
			set @errMsg = 'Summary for this month was not found';
			throw 57001, @errMsg, 1;
		end;
	end try
	begin catch
		set @errMsg=ERROR_MESSAGE();
	end catch;
go
begin tran t3
	declare @errMsg varchar(255);
	exec getMonthlySummaryOfUser 'pflorian', 2, @errMsg out;
rollback tran t3
