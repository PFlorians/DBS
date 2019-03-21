-- testing goes here
drop database attendance_dev
use attendance_dev;
begin tran t0
	declare @errMsg varchar(255);
	declare @recId int;
	declare @userExistsFlag bit;
	select * from attendance.attusr
	select * from attendance.shift
	select * from attendance.attendance_record;
	set datefirst 1
	select @@DATEFIRST
	exec userExists 'dhinojos', @userExistsFlag out, @errMsg out;
	if(@userExistsFlag = 0)
	begin
		exec init_user 'dhinojos', 2, '91238908', 'Desmond', 'Hinojos', 'Desmond.Hinojos@lehighhanson.com', @errMsg out;
	end;
	-- VOLN needs to be chosen if this is a weekend no matter what, sap is configured for Normal weekdays for GITC
	-- VOLN, 0100 and 8 hours are default values entered by program if this is a weekend
	-- normally all weekends have these values set to these values -> in case this is a regular weekend the arrival and update time are 00:00:00
	-- default values are automatically entered by program
	exec newAttendanceRecord 'pflorian', '05:53:15', 'D8',default,default,'01.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '05:55:23', 'D8',default,default,'02.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '06:01:19', 'D8',default,default,'03.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:50:04', 'O6',default,default,'04.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:57:43', 'O6',default,default,'05.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '14:05:12', 'O6',default,default,'06.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:51:33', 'O6',default,default,'07.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '13:57:25', 'O6',default,default,'08.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'09.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'10.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0100',8,'11.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0100',8,'12.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0100',8,'13.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0300',8,'14.02.2019', @errMsg=@errMsg, @recordId=@recId;
	-- duplicity test
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN','0310',8,'14.02.2019', @errMsg=@errMsg, @recordId=@recId;
	-- night shift test
	exec newAttendanceRecord 'pflorian', '17:54:25', 'N8',default,default,'15.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'16.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'17.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '18:01:12', 'N8',default,default,'18.02.2019', @errMsg=@errMsg, @recordId=@recId;

	select * from attendance.attendance_record;
	select * from attendance.recorded_shifts;
	select * from attendance.summary_absence;
	
	exec updateAttRecord @recId=1, @timeStringDepart='13:25:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=2, @timeStringDepart='13:31:26', @errMsg=@errMsg;
	exec updateAttRecord @recId=3, @timeStringDepart='13:11:10', @errMsg=@errMsg;
	exec updateAttRecord @recId=4, @timeStringDepart='20:01:11', @errMsg=@errMsg;
	exec updateAttRecord @recId=5, @timeStringDepart='20:11:03', @errMsg=@errMsg;
	exec updateAttRecord @recId=6, @timeStringDepart='20:06:03', @errMsg=@errMsg;
	exec updateAttRecord @recId=7, @timeStringDepart='20:09:27', @errMsg=@errMsg;
	exec updateAttRecord @recId=8, @timeStringDepart='20:04:41', @errMsg=@errMsg;
	-- this is supposed to be expected and automatic
	exec updateAttRecord @recId=9, @timeStringDepart='00:00:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=10, @timeStringDepart='00:00:00', @errMsg=@errMsg;
	-- absences
	exec updateAttRecord @recId=11, @timeStringDepart='08:00:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=12, @timeStringDepart='08:00:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=13, @timeStringDepart='08:00:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=14, @timeStringDepart='08:00:00', @errMsg=@errMsg;
	-- duplicity test
	-- throws error and makes transaction uncommitable, all other procedures woudl then catch another error
	--exec updateAttRecord @recId=14, @timeStringDepart='08:00:00', @errMsg=@errMsg; 
	exec updateAttRecord @recId=15, @timeStringDepart='08:00:00', @errMsg=@errMsg;
	--night shift
	exec updateAttRecord @recId=16, @timeStringDepart='00:00:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=17, @timeStringDepart='00:00:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=18, @timeStringDepart='06:02:11', @errMsg=@errMsg;
	
	select * from attendance.attusr
	select * from attendance.summary;
	select * from attendance.summary_bonuses;
	select * from attendance.summary_absence;
	select * from attendance.summary_public_holidays;
	select * from logs.summary_state_snapshot;
	select * from attendance.attendance_record;
	-- month of may test
	exec newAttendanceRecord 'pflorian', '05:57:15', 'D8',default,default,'01.05.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '05:51:29', 'D8',default,default,'02.05.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '06:00:49', 'D8',default,default,'03.05.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'04.05.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'pflorian', '00:00:00', 'VOLN',default,default,'05.05.2019', @errMsg=@errMsg, @recordId=@recId;
	
	select * from attendance.attendance_record;
	select * from attendance.recorded_shifts;
	

	exec updateAttRecord @recId=19, @timeStringDepart='13:25:00', @errMsg=@errMsg;
	exec updateAttRecord @recId=20, @timeStringDepart='13:31:26', @errMsg=@errMsg;
	exec updateAttRecord @recId=21, @timeStringDepart='13:11:10', @errMsg=@errMsg;
	exec updateAttRecord @recId=22, @timeStringDepart='20:01:11', @errMsg=@errMsg;
	exec updateAttRecord @recId=23, @timeStringDepart='20:11:03', @errMsg=@errMsg;
	select * from attendance.summary;
	select * from attendance.summary_bonuses;
	select * from attendance.summary_absence;
	select * from attendance.summary_public_holidays;
	select * from logs.summary_state_snapshot;
	select * from attendance.attendance_record;
	
	-- record alteration test
	-- update needs to get previous values subtract them from all counters and then perform regular update
	exec updateAttRecord @recId=20, @timeStringArrive='05:51:29', @timeStringDepart='14:26:11', @typeOfUpdate=1, @errMsg=@errMsg;
	exec updateAttRecord @recId=7, @timeStringArrive='05:51:29', @timeStringDepart='14:26:11', @shift='D8', @typeOfUpdate=1, @errMsg=@errMsg;
	select * from attendance.summary;
	select * from attendance.summary_bonuses;
	select * from attendance.summary_absence;
	select * from attendance.summary_public_holidays;
	select * from logs.summary_state_snapshot;
	select * from attendance.attendance_record;

	--user 2
	exec newAttendanceRecord 'dhinojos', '05:58:10', 'D8',default,default,'01.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'dhinojos', '05:59:21', 'D8',default,default,'02.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'dhinojos', '06:00:03', 'D8',default,default,'03.02.2019', @errMsg=@errMsg, @recordId=@recId;

	select * from attendance.attendance_record;
	select * from attendance.recorded_shifts;
	exec updateAttRecord @recId=24, @timeStringDepart='13:08:10', @errMsg=@errMsg;
	exec updateAttRecord @recId=25, @timeStringDepart='13:03:01', @errMsg=@errMsg;
	exec updateAttRecord @recId=26, @timeStringDepart='13:09:17', @errMsg=@errMsg;
	select * from attendance.summary;
	select * from attendance.summary_bonuses;
	select * from attendance.summary_absence;
	select * from attendance.summary_public_holidays;
	select * from logs.summary_state_snapshot;
	select * from attendance.attendance_record;
commit tran t0;
begin tran t1
	declare @errMsg varchar(255);
	declare @recId int;
	set datefirst 1
	exec newAttendanceRecord 'dhinojos', '05:58:10', 'D8',default,default,'01.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'dhinojos', '05:59:21', 'D8',default,default,'02.02.2019', @errMsg=@errMsg, @recordId=@recId;
	exec newAttendanceRecord 'dhinojos', '06:00:03', 'D8',default,default,'03.02.2019', @errMsg=@errMsg, @recordId=@recId;

	select * from attendance.attendance_record;
	select * from attendance.recorded_shifts;
rollback tran t1
	
/* if committed delete everyting from everywhere
	delete from attendance.recorded_shifts where 1=1
	delete from attendance.summary_absence where 1=1
	delete from attendance.summary_bonuses where 1=1
	delete from attendance.summary_public_holidays where 1=1
	delete from attendance.summary where 1=1

	delete from attendance.attendance_record where 1=1;

	delete from logs.records_changes where 1=1;
	delete from logs.record_change_log where 1=1;
	delete from logs.summary_state_snapshot where 1=1;
	*/

--commit tran t0
	dbcc checkident ('attendance.attendance_record', reseed, 0);
	dbcc checkident ('attendance.recorded_shifts', reseed, 0);
	dbcc checkident ('attendance.summary', reseed, 0);
	dbcc checkident ('attendance.summary_bonuses', reseed, 0);
	dbcc checkident ('attendance.summary_absence', reseed, 0);
	dbcc checkident ('attendance.summary_public_holidays', reseed, 0);
	dbcc checkident ('logs.records_changes', reseed, 0);
	dbcc checkident ('logs.record_change_log', reseed, 0);
	dbcc checkident ('logs.summary_state_snapshot', reseed, 0);
	
