create database attendance_dev;
go
create schema attendance authorization db_owner
go
create schema logs authorization db_owner
go
-- creation of tables 
create table attendance.attusr
(
ulogin varchar(40) primary key,
user_typeId int,
eid numeric not null unique,
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
	[from] datetime,
	until datetime,
	hours_worked_day real not null,
	[day] date not null
);
go
create table attendance.summary
(
	summary_id int identity(1, 1) primary key,
	record_id int not null,
	hours_worked_month real not null,
	hours_overtime_month real not null,
	hours_absent_month real not null
);
go
create table attendance.overtime
(
	overtime_id varchar(4) primary key not null,
	descr varchar(100) not null
);
go
create table attendance.summarys_overtimes
(
	id int identity(1, 1) primary key,
	overtime_id varchar(4) not null,
	summary_id int not null,
	[day] date not null,
	hours_overtime real not null
);
go
create table attendance.absence
(
	[type] varchar(4) not null primary key,
	descr varchar(255) not null
);
go
create table attendance.recorded_absence
(
	id int identity(1, 1) primary key,
	absence_type varchar(4) not null,
	summary_id int not null,
	day_of_absence date not null,
	hours_absent real not null
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
create table attendance.[month]
(
	id int identity(1, 1) primary key,
	[month] varchar(20) not null
);
go
create table attendance.recorded_months
(
	id int identity(1, 1) primary key,
	record_id int not null,
	monthId int not null
);
go
create table attendance.[shift]
(
	[type] varchar(8) primary key not null,
	descr varchar(255) not null
);
go
create table attendance.recorded_shifts
(
	id int identity(1, 1) primary key,
	record_id int not null,
	shifttype varchar(255) not null
);
go
--alterations
alter table logs.user_changes add constraint 
	FK_uchanges_logId foreign key (log_id) references logs.user_change_log(log_id)
