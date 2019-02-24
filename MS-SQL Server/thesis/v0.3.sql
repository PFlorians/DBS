create database attendance_dev;
use attendance_dev
go
create schema attendance authorization db_owner
go
create schema logs authorization db_owner
go
-- this is set only because by default in U.S. the first working day is sunday so datefirst counts from sunday
set datefirst 1
go
-- to purge indexes:
-- dbcc checkident (<table>, reseed, 0)
-- creation of tables 
create table attendance.attusr
(
ulogin varchar(40) primary key,
user_typeId int,
eid varchar(20) not null unique,
name varchar(50) not null,
lastname varchar(50) not null,
email varchar(100) not null unique
);
go
create table attendance.user_type
(
	id int identity(1, 1) primary key,
	descr varchar(100) not null unique
);
go
create table logs.user_changes
(
	id int identity(1, 1) primary key,
	log_id int not null,
	userLogin varchar(40) not null
);
go
create table logs.user_change_log
(
	log_id int identity(1, 1) primary key,
	log_time datetime2 not null
);
go
create table attendance.attendance_record
(
	record_id int identity(1, 1) primary key,
	userLogin varchar(40) not null,
	[from] time,
	until time,
	hours_worked_day real not null,
	[day] date not null
);
go
create table attendance.summary
(
	summary_id int identity(1, 1) primary key,
	record_id int not null,
	hours_worked_month real not null,
	bonus_hours_month real not null,
	hours_absent_month real not null
);
go
create table attendance.bonus
(
	bonus_id varchar(4) primary key not null,
	descr varchar(100) not null,
	[% bonus] int not null
);
go 
create table attendance.summary_bonuses
(
	id int identity(1, 1) primary key,
	bonus_id varchar(4) not null,
	summary_id int not null,
	[day] date not null,
	bonus_hours real not null
);
go
create table attendance.absence
(
	[type] varchar(4) not null primary key,
	descr varchar(255) not null
);
go
create table attendance.summary_absence
(
	id int identity(1, 1) primary key,
	absence_type varchar(4) not null,
	summary_id int not null,
	day_of_absence date not null,
	hours_absent real not null
);
go
create table attendance.recorded_absence
(
	id int identity(1, 1) primary key,
	record_id int not null,
	type varchar(4) not null,
	absence_length real not null default 8.0
);
go
create table logs.record_change_log
(
	log_id int identity(1, 1) primary key,
	change_timestamp datetime2 not null
);
go
create table logs.records_changes
(
	id int identity(1, 1) primary key,
	record_id int not null,
	log_id int not null
);
go
create table attendance.[shift]
(
	[type] varchar(8) primary key not null,
	planned_hours_work real not null,
	start_time time not null,
	end_time time not null
);
go
create table attendance.recorded_shifts
(
	id int identity(1, 1) primary key,
	record_id int not null,
	shifttype varchar(8) not null
);
go
create table attendance.public_holidays
(
	id int identity(1, 1) primary key,
	[date] date not null
);
go
create table attendance.summary_public_holidays
(
	id int identity(1, 1) primary key,
	summary_id int not null,
	public_holiday_id int not null
);
go
--alterations
alter table attendance.summary_public_holidays add constraint
	FK_summId_summID foreign key(summary_id) references attendance.summary(summary_id);
alter table attendance.summary_public_holidays add constraint
	FK_pubHolId_pubHolId foreign key (public_holiday_id) references attendance.public_holidays(id);
go
alter table logs.user_changes add constraint 
	FK_uchanges_logId foreign key (log_id) references logs.user_change_log(log_id);
alter table logs.user_changes add constraint
	FK_uchanges_uLogin foreign key (userLogin) references attendance.attUsr(ulogin);
go
alter table attendance.attusr add constraint
	FK_attusr_uTypeId foreign key (user_typeId) references attendance.user_type(id);
go
alter table attendance.attendance_record add constraint
	FK_attRecord_ulogin foreign key (userlogin) references attendance.attusr(ulogin);
go
alter table logs.records_changes add constraint
	FK_recordid_attRecId foreign key (record_id) references attendance.attendance_record(record_id);
alter table logs.records_changes add constraint
	FK_logId_recordChangeLogLogId foreign key (log_id) references logs.record_change_log(log_id);
go
alter table attendance.recorded_shifts add constraint
	FK_recordId_attendanceRecordRecId foreign key (record_id) references attendance.attendance_record(record_id);
alter table attendance.recorded_shifts add constraint
	FK_shiftType_shiftType foreign key (shiftType) references attendance.shift(type);
go
alter table attendance.summary add constraint
	FK_recordId_attRecordRecId foreign key(record_id) references attendance.attendance_record(record_id);
go
alter table attendance.summary_bonuses add constraint
	FK_bonusId_bonusId foreign key(bonus_id) references attendance.bonus(bonus_id);
alter table attendance.summary_bonuses add constraint
	FK_summaryID_summarySummaryId foreign key (summary_id) references attendance.summary(summary_id);
go
alter table attendance.summary_absence add constraint
	FK_absenceType_sumAbsType foreign key (absence_type) references attendance.absence(type);
alter table attendance.summary_absence add constraint
	FK_summaryId_summaryId foreign key(summary_id) references attendance.summary(summary_id);
go
alter table attendance.recorded_absence add constraint
	FK_recAbsRecordId_attRecRecId foreign key (record_id) references attendance.attendance_record(record_id);
alter table attendance.recorded_absence add constraint 
	FK_reckAbsType_absType foreign key(type) references attendance.absence(type);
go -- end of FK alterations
-- other alterations
-- uistime sa ze bonus je % medzi 0 a 100, pricom 0 nemaz vyznam
alter table attendance.bonus add constraint
	CHK_percentage check ([% bonus] >=0 and [% bonus] <=100);
go
-- hardcoded data goes here
insert into attendance.public_holidays([date])
	values
		(convert(date, '01.01.2019', 104)), (convert(date, '19.04.2019', 104)), (convert(date, '22.04.2019', 104)),
		(convert(date, '01.05.2019', 104)), (convert(date, '08.05.2019', 104)), (convert(date, '05.07.2019', 104)),
		(convert(date, '06.07.2019', 104)), (convert(date, '28.09.2019', 104)), (convert(date, '28.10.2019', 104)),
		(convert(date, '17.11.2019', 104)), (convert(date, '24.12.2019', 104)), (convert(date, '25.12.2019', 104)),
		(convert(date, '26.12.2019', 104));

insert into attendance.user_type(descr)
values
('user'), ('team leader'), ('administrator');

insert into attendance.bonus(bonus_id, descr, [% bonus])
	values
	('0110', 'Afternoon shift', 15), ('0123', 'Night Shift GITC', 20),
	('0130', 'Saturday + Sunday', 29), ('0140', 'Public holiday', 100),
	('0160', 'Workday overtime', 25), ('0161', 'Weekend, holiday overtime', 50),
	 ('0300', 'Emergency workdays', 25), ('0301', 'Emergency weekend, holidays', 15);

insert into attendance.absence(type, descr)
values
('0100', 'Vacation'), ('0110', 'Personal issue paid by employees average'),
('0120', 'Personal issue unpaid'), ('0130', 'Restriction due to public interest'),
('0140', 'Military excercise'), ('0180', 'Idle time paid by average'),
('0181', 'Idle time paid by tariph'), ('0199', 'Other restrictions paid by average'),
('0205', 'Illnes(any unpaid type), occupational disease, maternity leave, parental, (everything paid by health insurance)'),
('0300', 'Unpaid leave'), ('0310', 'Unauthorized absence'), ('0410', 'Substitute leave for a public holiday');

insert into attendance.shift(type, planned_hours_work, start_time, end_time) 
values
('D8', 7.50, '06:00:00', '14:00:00'), ('N12', 11.00, '18:00:00', '06:00:00'),
('N8', 7.50, '22:00:00', '06:00:00'), ('N825', 7.75, '21:45:00', '06:00:00'),
('N8X', 8.00, '22:00:00', '06:00:00'), ('O10', 9.50, '12:00:00', '22:00:00'),
('O6', 5.50, '14:00:00', '20:00:00'), ('O7', 6.50, '14:30:00', '21:30:00'),
('O75', 7.00, '14:30:00', '22:00:00'), ('O8', 7.50, '14:00:00', '22:00:00'),
('O810', 7.50, '10:00:00', '18:00:00'), ('O812', 7.50, '12:00:00', '20:00:00'),
('O813', 7.50, '13:00:00', '21:00:00'), ('O825', 7.75, '14:00:00', '22:15:00');
insert into attendance.shift(type, planned_hours_work, start_time, end_time) 
values
('O85', 8, '14:00:00', '22:30:00'), ('O8X', 8, '14:00:00', '22:00:00'),
('O9', 8.50, '14:00:00', '23:00:00'), ('O95', 9, '14:00:00', '23:30:00'),
('P750', 7.50, '06:00:00', '14:00:00'), ('P8', 8, '06:00:00', '18:00:00'),
('P85', 8.50, '06:00:00', '18:00:00'), ('P9', 9, '06:00:00', '18:00:00'),
('R10', 9.50, '06:00:00', '16:00:00'), ('R105', 10.00, '06:00:00', '16:30:00'),
('R10Q', 10.00, '06:00:00', '16:00:00'), ('R11Q', 11.00, '06:00:00', '17:00:00'),
('R12', 11, '06:00:00', '18:00:00'), ('R12B', 11.50, '06:00:00', '18:00:00');
insert into attendance.shift(type, planned_hours_work, start_time, end_time) 
values
('R15Q', 10.50, '06:00:00', '16:30:00'), ('R15T', 10.00, '06:00:00', '16:30:00'),
('R45Q', 4.50, '06:00:00', '10:30:00'), ('R46T', 4.50, '06:00:00', '10:30:00'),
('R4Q', 4.00, '06:00:00', '10:00:00'), ('R5', 5, '07:00:00', '12:00:00');
insert into attendance.shift(type, planned_hours_work, start_time, end_time) 
values
('R55', 5.50, '06:00:00', '12:00:00'), ('R55Q', 5.50, '06:00:00', '11:30:00'),
('R56T', 5, '06:00:00', '11:00:00'), ('R5Q', 5, '06:00:00', '11:00:00'),
('R6', 5.50, '06:00:00', '12:00:00'), ('R65', 6, '06:00:00', '12:30:00'),
('R65B', 6, '06:00:00', '12:00:00'), ('R65Q', 6.50, '06:00:00', '11:30:00'),
('R65T', 6, '06:00:00', '12:30:00'), ('R6Q', 6, '06:00:00', '12:00:00'),
('R7', 6.50, '06:00:00', '13:00:00'), ('R75', 7, '06:00:00', '13:30:00'),
('R75B', 7, '06:00:00', '13:30:00'), ('R75Q', 7.50, '06:00:00', '13:30:00'),
('R75T', 7.00, '06:00:00', '13:30:00'), ('R7Q', 7, '06:00:00', '13:00:00'),
('R7T', 6.50, '06:00:00', '13:00:00'), ('R8', 7.50, '06:00:00', '14:00:00'),
('R800', 7.50, '08:00:00', '16:00:00'), ('R825', 7.75, '05:45:00', '14:00:00'),
('R85', 8, '06:00:00', '14:30:00'), ('R853', 7.50, '05:30:00', '13:30:00'),
('R85B', 8, '06:00:00', '14:30:00'), ('R85Q', 8.50, '06:00:00', '14:30:00'),
('R85T', 8, '06:00:00', '14:30:00'), ('R863', 7.50, '06:30:00', '14:30:00'),
('R870', 7.50, '07:00:00', '15:00:00'), ('R873', 7.50, '07:30:00', '15:30:00'),
('R8Q', 8, '06:00:00', '14:00:00'), ('R8T', 7.50, '06:00:00', '14:00:00'),
('R8X', 8, '06:00:00', '15:00:00'), ('R9', 8.50, '06:00:00', '15:00:00'),
('R95', 9, '06:00:00', '15:30:00'), ('R95B', 9, '06:00:00', '15:30:00'),
('R95Q', 9.50, '06:00:00', '15:30:00'), ('R95T', 9, '06:00:00', '16:00:00'),
('R9Q', 9, '06:00:00', '15:00:00'), ('R9T', 8.50, '06:00:00', '15:00:00'),
('VOLN', 0, '00:00:00', '00:00:00');

-- dummy users

insert into attendance.attusr (ulogin, user_typeid, eid, name, lastname, email)
values
('pflorian', 1, '88000415', 'Patrik', 'Florians', 'Patrik.Florians@heidelbergcement.com'),
('xpflori05', 2, '1295467', 'Kirtap', 'Snairolf', 'xpflori05@vutbr.cz'),
('xflori10', 3, '5467898', 'Erik', 'Morris', 'morris@morriscorp.com');
-- procedures go here
go
-- this procedure inserts records to all tables given a specific parameters
-- Required parameters are as follows:
-- user login
-- shift type
-- beginning of work -> end should be handled by updater procedure
-- hours worked should be set to 0 upon initiation -> should be updated on check
create proc newAttendanceRecord
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
			set @errMsg = 'User or shift not found';
			set @recordId = -1;
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

-- procedure which gets monthly record of users attendance
-- this shows only records by month
-- more detailed procedure contains also summary
create proc getUsersAttendanceByMonth
@ulogin varchar(40),
@month int,
@errMsg varchar(255) output
as
	begin try
		select ar.record_id [record_id], ar.[from] [from], ar.until [until], 
				ar.hours_worked_day [hours_worked], ar.[day] [day]
		from attendance.attendance_record as ar
		where ar.userLogin = @ulogin;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
-- summary procedure -> should be called mostly by checkEndMonth trigger
--
alter proc determineEmergency
@hours_worked_day real,
@absenceType varchar(4),
@lastShift varchar(8),
@summaryId int,
@lastDate date,
@errMsg varchar(255) output
as
	begin try
		declare @monthlyHours real;
		declare @emergencyPresent bit;
		set @emergencyPresent = 0;
		if((@hours_worked_day > 0 )and (@absenceType is null) and (@lastShift like 'VOLN'))
		begin
			if(datepart(WEEKDAY, @lastDate)>=6 or (@lastDate in (select [date] from attendance.public_holidays)))
			begin
				insert into attendance.summary_bonuses(bonus_id, summary_id, day, bonus_hours)
					values('0301', @summaryID, @lastDate, @hours_worked_day*(select top 1 [% bonus]/100.0 
																				from attendance.bonus
																				where bonus_id like '0301'));
				set @emergencyPresent = 1; --indicates that emergency was present it is safe to update
			end;
			else if(datepart(WEEKDAY, @lastDate)<6)
			begin
				insert into attendance.summary_bonuses(bonus_id, summary_id, day, bonus_hours)
					values('0300', @summaryId, @lastDate, @hours_worked_day*(select top 1 [% bonus]/100.0 
																				from attendance.bonus
																				where bonus_id like '0300'));
				set @emergencyPresent = 1;
			end;
			if(@emergencyPresent <> 0) -- safe to update if this is was an emergency call
			begin
				set @monthlyHours = (select top 1 bonus_hours_month from attendance.summary
									where summary_id=@summaryId);
				if((select top 1 bonus_hours from attendance.summary_bonuses
													where id=(IDENT_CURRENT('attendance.summary_bonuses'))) is null)
				begin
					set @monthlyHours = @monthlyHours + 0;
				end;
				else
				begin
					set @monthlyHours = @monthlyHours + (select top 1 bonus_hours from attendance.summary_bonuses
													where id=(IDENT_CURRENT('attendance.summary_bonuses')));
				end;
				-- update summary -> bonuses
				update attendance.summary 
					set bonus_hours_month = @monthlyHours
					where summary_id = @summaryId;	
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
alter proc determineOvertime
@hours_worked_day real,
@expectedWorkTime real,
@lastShift varchar(8),
@lastDate date,
@summaryId int,
@errMsg varchar(255) output,
@overtimePresent real output
as
	begin try
		declare @overtime real;
		declare @monthlyHours real;
		set @overtimePresent = 0.0;
		if(((@hours_worked_day - @expectedWorkTime) > 0) 
		and ((datepart(WEEKDAY, @lastDate) >= 6) or (@lastDate in (select [date] from attendance.public_holidays)))
		and (@lastShift not like 'VOLN'))
		begin
			set @overtime = 50;
			set @overtimePresent = (@hours_worked_day - @expectedWorkTime);
			insert into attendance.summary_bonuses(bonus_id, summary_id, day, bonus_hours)
				values ('0161', @summaryId, @lastDate, (@overtime/100.0)*(@hours_worked_day - @expectedWorkTime));
		end;
		else if(((@hours_worked_day - @expectedWorkTime) > 0) and 
		(datepart(WEEKDAY, @lastDate) < 6) and 
		(@lastShift not like 'VOLN'))
		begin
			set @overtime = 25;
			set @overtimePresent = (@hours_worked_day - @expectedWorkTime);
			insert into attendance.summary_bonuses(bonus_id, summary_id, day, bonus_hours)
				values ('0160', @summaryId, @lastDate, (@overtime/100.0)*(@hours_worked_day - @expectedWorkTime));
		end;
		-- update to increase the overall value
		if(@overtimePresent > 0) --safe to update if overtime was achieved
		begin
			set @monthlyHours = (select top 1 bonus_hours_month from attendance.summary
								where summary_id=@summaryId);
			if((select top 1 bonus_hours from attendance.summary_bonuses
													where id=(IDENT_CURRENT('attendance.summary_bonuses'))) is null)
			begin
				set @monthlyHours = @monthlyHours + 0;
			end;
			else
			begin
				set @monthlyHours = @monthlyHours + (select top 1 bonus_hours from attendance.summary_bonuses
												where id=(IDENT_CURRENT('attendance.summary_bonuses')));
			end;
			-- update summary -> bonuses
			update attendance.summary 
				set bonus_hours_month = @monthlyHours
				where summary_id = @summaryId;	
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
alter proc determineBonus
@lastShift varchar(8),
@lastDate date,
@summaryId int,
@hours_worked_day real,
@errMsg varchar(255) output
as
	begin try
		declare @monthlyHours real;
		
		if((@lastShift like '[NO]%') or (DATEPART(weekday, @lastDate) >= 6))
		begin
			insert into attendance.summary_bonuses(bonus_id, summary_id, day, bonus_hours)
				select (case 
							when @lastShift like 'O%' then '0110' 
							when @lastShift like 'N%' then '0123'
							when ((DATEPART(weekday, convert(date, @lastDate, 101)) = 6) or 
								(DATEPART(weekday, convert(date, @lastDate, 101)) = 7)) then '0130'
							when (convert(date, @lastDate, 101) in (select [date] from attendance.public_holidays))
								then '0140'
						end) as bonus_id, @summaryId as summary_id, @lastDate as day, 
						(case
							when @lastShift like 'O%' then (@hours_worked_day*(select top 1 [% bonus]/100.0 
																				from attendance.bonus
																				where bonus_id like '0110'))
							when @lastShift like 'N%' then (@hours_worked_day*(select top 1 [% bonus]/100.0 
																				from attendance.bonus
																				where bonus_id like '0123'))
							when ((DATEPART(weekday, convert(date, @lastDate, 101)) = 6) or 
								(DATEPART(weekday, convert(date, @lastDate, 101)) = 7)) then 
															(@hours_worked_day*(select top 1 [% bonus]/100.0 
																				from attendance.bonus
																				where bonus_id like '0130'))
							when (convert(date, @lastDate, 101) in (select [date] from attendance.public_holidays))
								then (@hours_worked_day*(select top 1 [% bonus]/100.0 
														from attendance.bonus
														where bonus_id like '0140'))
						end) as bonus_hours;
			set @monthlyHours = (select top 1 bonus_hours_month from attendance.summary
									where summary_id=@summaryId);
			if((select top 1 bonus_hours from attendance.summary_bonuses
												where id=(IDENT_CURRENT('attendance.summary_bonuses'))) is null)
			begin
				set @monthlyHours = @monthlyHours + 0;
			end;
			else
			begin
				set @monthlyHours = @monthlyHours + (select top 1 bonus_hours from attendance.summary_bonuses
												where id=(IDENT_CURRENT('attendance.summary_bonuses')));
			end;
			-- update summary -> bonuses
			update attendance.summary 
				set bonus_hours_month = @monthlyHours
				where summary_id = @summaryId;
		end;	
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
alter proc determineAbsence
@lastShift varchar(8),
@absenceType varchar(4),
@summaryId int,
@lastDate date,
@lastRecId int,
@errMsg varchar(255) output
as
	begin try
		declare @monthlyHours real;
		declare @absenceLength real;
		if((@lastShift like 'VOLN') and (@absenceType is not null)) 
		begin
			set @absenceLength = (select top 1 absence_length from attendance.recorded_absence where record_id=@lastRecId order by record_id desc);
			insert into attendance.summary_absence(absence_type, summary_id, day_of_absence, hours_absent)
				values(@absenceType, @summaryId, @lastDate, @absenceLength);
			
			--update overall absence
			set @monthlyHours = (select top 1 hours_absent_month from attendance.summary
								where summary_id=@summaryId);
			set @monthlyHours = @monthlyHours + @absenceLength;
				
			update attendance.summary 
				set hours_absent_month = @monthlyHours
				where summary_id = @summaryId;	
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
create proc fullCheck
@ulogin varchar(40),
@lastDate date,
@hours_worked_day real,
@lastRecId int,
@summaryCreated int,
@lastShift varchar(8), 
@expectedWorkTime real,
@absenceType varchar(4),
@errMsg varchar(255) output
as
	declare @monthlyHours real;
	declare @overtimePresent real;

	set @overtimePresent =0.0;
	begin try
		if(@summaryCreated is not null)
		begin
			set @monthlyHours = (select top 1 hours_worked_month from attendance.summary
									where summary_id=@summaryCreated);
			set @monthlyHours = @monthlyHours + @hours_worked_day;
			-- update summary -> bonuses
			update attendance.summary 
				set hours_worked_month = @monthlyHours
				where summary_id = @summaryCreated;
								-- determine if emergency
			exec determineEmergency @hours_worked_day, @absenceType, @lastShift, @summaryCreated, @lastDate, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining emergency: ' + @errMsg;
			end;
			else
			begin
				-- determine if employee should be paid overtime
				exec determineOvertime @hours_worked_day, @expectedWorkTime, @lastShift, @lastDate, @summaryCreated, @errMsg out, @overtimePresent out;
				set @hours_worked_day = @hours_worked_day - @overtimePresent;-- this can only be done here not earlier not later
				if(@errMsg is not null)
				begin
					print 'Error determining overtime: ' + @errMsg;
				end;
			end;
			-- determine any other bonus
			exec determineBonus @lastShift, @lastDate, @summaryCreated, @hours_worked_day, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining bonuses: ' + @errMsg;
			end;
		end; -- if summary existed flow ends here
		else -- if summary doesn't yet exists, flow starts here
		begin
			insert into attendance.summary(record_id, hours_worked_month, hours_absent_month, bonus_hours_month)
				values(@lastRecId, @hours_worked_day, 0, 0);
			set @summaryCreated = IDENT_CURRENT('attendance.summary');
			-- determine if emergency
			exec determineEmergency @hours_worked_day, @absenceType, @lastShift, @summaryCreated, @lastDate, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining emergency 2: ' + @errMsg;
			end;
			else
			begin
				-- determine if employee should be paid overtime
				exec determineOvertime @hours_worked_day, @expectedWorkTime, @lastShift, @lastDate, @summaryCreated, @errMsg out, @overtimePresent out;
				set @hours_worked_day = @hours_worked_day - @overtimePresent; -- this can only be done here not earlier not later
				if(@errMsg is not null)
				begin
					print 'Error determining overtime 2: ' + @errMsg;
				end;
			end;
			-- determine any other bonus
			exec determineBonus @lastShift, @lastDate, @summaryCreated, @hours_worked_day, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining bonuses 2: ' + @errMsg;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
alter proc absenceChecker
@ulogin varchar(40),
@lastDate date,
@hours_worked_day real,
@lastRecId int,
@summaryCreated int,
@lastShift varchar(8), 
@expectedWorkTime real,
@absenceType varchar(4),
@errMsg varchar(255) output
as
	begin try
		if(@summaryCreated is not null)
		begin
		-- determine if absence
			exec determineAbsence @lastShift, @absenceType, @summaryCreated, @lastDate, @lastRecId, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining absence absenceChecker 1: ' + @errMsg;
			end;
		end;
		else
		begin
			insert into attendance.summary(record_id, hours_worked_month, hours_absent_month, bonus_hours_month)
				values(@lastRecId, @hours_worked_day, 0, 0);
			set @summaryCreated = IDENT_CURRENT('attendance.summary');
			exec determineAbsence @lastShift, @absenceType, @summaryCreated, @lastDate, @lastRecId, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining absence absenceChecker 2: ' + @errMsg;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
alter proc summaryUpdater
@ulogin varchar(40),
@lastDate date,
@hours_worked_day real,
@lastRecId int,
@errMsg varchar(255) output
as
	declare @summaryCreated int;
	declare @monthlyHours real;
	declare @lastShift varchar(8);
	declare @expectedWorkTime real;
	declare @absenceType varchar(4);
	declare @overtimePresent real;

	set @overtimePresent =0.0;
	begin try
		--verify if a summary for a given user in a given month's records exists
		-- of so, no new shall be created, otherwise create a new one
		
		set @summaryCreated = (select top 1 asu.summary_id from attendance.attusr as au
			join attendance.attendance_record as ar on ar.userLogin = au.ulogin
			join attendance.summary as asu on asu.record_id=ar.record_id
			where ar.userLogin = @ulogin and (MONTH(@lastDate) = MONTH(ar.[day]))
			order by ar.record_id asc);
		
		set @lastShift = (select top 1 shifttype from attendance.recorded_shifts where record_id=@lastRecId order by id desc);
		set @expectedWorkTime = (select top 1 planned_hours_work from attendance.shift where [type]=@lastShift);
		set @absenceType = (select top 1 [type] from attendance.recorded_absence 
							where record_id=@lastRecId order by id desc);
		-- deciding whether this is an absence or not
		-- if yes, then there can be no bonuses, just record absence, thats it
		-- if something is a weekend, do nothing
		if(@expectedWorkTime <> 0)
		begin
			print 'prva';
		end;
		if(@lastShift not like 'VOLN')
		begin
			print 'druha';
		end;
		if(@absenceType is null)
		begin 
			print 'tretia';
		end;
		if(@expectedWorkTime = 0.0 and @hours_worked_day <> 0.0 and @lastShift like 'VOLN' and @absenceType not like '')
		begin
			exec absenceChecker @ulogin, @lastDate, @hours_worked_day, @lastRecId, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining absence summaryChecker: ' + @errMsg;
			end;
		end;
		else if(@expectedWorkTime <> 0 and (@lastShift not like 'VOLN') and (@absenceType like '' or @absenceType is null))
		begin
			exec fullCheck @ulogin, @lastDate, @hours_worked_day, @lastRecId, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining absence summaryChecker - fullCheck: ' + @errMsg;
			end;	
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
--triggers go here
alter trigger attendance.summaryUpdateSubroutine
	on attendance.attendance_record
		for update
as
	declare @insDate date;
	declare @ulogin varchar(40);
	declare @hours_worked_day real;
	declare @lastRecId int;
	declare @errMsg varchar(255);

	set @insDate = (select top 1 [day] from inserted);
	set @ulogin = (select top 1 userlogin from inserted);
	set @hours_worked_day = (select top 1 hours_worked_day from inserted);
	set @lastRecId = (select top 1 record_id from inserted);
	
	exec summaryUpdater @ulogin, @insDate, @hours_worked_day, @lastRecId, @errMsg=@errMsg;
	if(@errMsg is not null)
	begin
		print 'Updater trigger reporting failure: ' + @errMsg;
	end;
go
-- logging procedures
create proc logUserChange
@ulogin varchar(40),
@errMsg varchar(255) output
as
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
		end;
	end try
	begin catch
		set @errMsg = Error_message();
	end catch;
go
create proc logRecordChange
@recId int,
@errMsg varchar(255) output
as
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
			set @errMsg = 'Error record not found';
		end;
	end try
	begin catch
		set @errMsg = error_message();
	end catch;
go
-- Data read procedures go here
go
-- testing goes here
begin tran t0
	declare @errMsg varchar(255);
	declare @recId int;
	select * from attendance.attusr
	select * from attendance.shift
	select * from attendance.attendance_record;
	set datefirst 1
	select @@DATEFIRST
	exec newAttendanceRecord 'pflorian', '05:53:15', 'D8',default,default,'01.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '05:55:23', 'D8',default,default,'02.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '06:01:19', 'D8',default,default,'03.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:50:04', 'O6',default,default,'04.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:57:43', 'O6',default,default,'05.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '14:05:12', 'O6',default,default,'06.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:51:33', 'O6',default,default,'07.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:57:25', 'O6',default,default,'08.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'09.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'10.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0100',8,'11.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0100',8,'12.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0100',8,'13.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0300',8,'14.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0310',8,'14.02.2019', 1, @errMsg=@errMsg, @recordId=@recId;
	
	select * from attendance.attendance_record;
	select * from attendance.recorded_shifts;
	select * from attendance.recorded_absence;

	exec updateAttRecord 1, '13:25:00', @errMsg=@errMsg;
	exec updateAttRecord 2, '13:31:26', @errMsg=@errMsg;
	exec updateAttRecord 3, '13:11:10', @errMsg=@errMsg;
	exec updateAttRecord 4, '20:01:11', @errMsg=@errMsg;
	exec updateAttRecord 5, '20:11:03', @errMsg=@errMsg;
	exec updateAttRecord 6, '20:06:03', @errMsg=@errMsg;
	exec updateAttRecord 7, '20:09:27', @errMsg=@errMsg;
	exec updateAttRecord 8, '20:04:41', @errMsg=@errMsg;
	-- this is supposed to be expected and automatic
	exec updateAttRecord 9, '00:00:00', @errMsg=@errMsg;
	exec updateAttRecord 10, '00:00:00', @errMsg=@errMsg;
	-- absences
	exec updateAttRecord 11, '08:00:00', @errMsg=@errMsg;
	exec updateAttRecord 12, '08:00:00', @errMsg=@errMsg;
	exec updateAttRecord 13, '08:00:00', @errMsg=@errMsg;
	exec updateAttRecord 14, '08:00:00', @errMsg=@errMsg;
	exec updateAttRecord 15, '08:00:00', @errMsg=@errMsg;

	select * from attendance.summary;
	select * from attendance.summary_bonuses;
	select * from attendance.summary_absence;
	select * from attendance.summary_public_holidays;
	
	dbcc checkident ('attendance.attendance_record', reseed, 0);
	dbcc checkident ('attendance.recorded_shifts', reseed, 0);
	dbcc checkident ('attendance.recorded_absence', reseed, 0);
	dbcc checkident ('attendance.summary', reseed, 0);
	dbcc checkident ('attendance.summary_bonuses', reseed, 0);
	dbcc checkident ('attendance.summary_absence', reseed, 0);
	dbcc checkident ('attendance.summary_public_holidays', reseed, 0);
rollback tran t0;
