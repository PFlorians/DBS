create schema attendance authorization [GROUPHC\pafloria]
go
create schema logs authorization [GROUPHC\pafloria]
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
	change_timestamp datetime2 not null,
	type_of_change smallint
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
	public_holiday_id int not null,
	hours_worked real not null
);
go
create table logs.summary_state_snapshot
(
	id int identity(1, 1) primary key,
	[timestamp] datetime not null,
	hours_worked_month_snap real ,
	bonus_hours_month_snap real ,
	hours_absent_monh_snap real ,
	hours_worked_inserted real ,
	summary_id int
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
alter table logs.summary_state_snapshot add constraint
	FK_sumId_asSumId foreign key(summary_id) references attendance.summary(summary_id);
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
go
