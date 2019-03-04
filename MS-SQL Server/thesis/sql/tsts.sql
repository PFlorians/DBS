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
	-- duplicity test
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
	-- duplicity test
	exec updateAttRecord 14, '08:00:00', @errMsg=@errMsg;
	exec updateAttRecord 15, '08:00:00', @errMsg=@errMsg;

	select * from attendance.summary;
	select * from attendance.summary_bonuses;
	select * from attendance.summary_absence;
	select * from attendance.summary_public_holidays;
/* if committed delete everyting from everywhere	
	delete from attendance.recorded_shifts where 1=1
	delete from attendance.summary_absence where 1=1
	delete from attendance.summary_bonuses where 1=1
	delete from attendance.summary_public_holidays where 1=1
	delete from attendance.summary where 1=1
	delete from attendance.recorded_absence where 1=1;

	delete from attendance.attendance_record where 1=1;

	delete from logs.records_changes where 1=1;
	delete from logs.record_change_log where 1=1;
	*/
--rollback tran t0
commit tran t0
	dbcc checkident ('attendance.attendance_record', reseed, 0);
	dbcc checkident ('attendance.recorded_shifts', reseed, 0);
	dbcc checkident ('attendance.recorded_absence', reseed, 0);
	dbcc checkident ('attendance.summary', reseed, 0);
	dbcc checkident ('attendance.summary_bonuses', reseed, 0);
	dbcc checkident ('attendance.summary_absence', reseed, 0);
	dbcc checkident ('attendance.summary_public_holidays', reseed, 0);
	dbcc checkident ('logs.records_changes', reseed, 0);
	dbcc checkident ('logs.record_change_log', reseed, 0);
