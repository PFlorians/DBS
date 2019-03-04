-- script should containt only trigger and procedures used for value calculation
-- this procedure determines whether an emergency was in progress
alter proc determineEmergency
@hours_worked_day real,
@absenceType varchar(4),
@lastShift varchar(8),
@summaryId int,
@lastDate date,
@errMsg varchar(255) output
as
	set datefirst 1;
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
	set datefirst 1;															
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
	set datefirst 1;														
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
	set datefirst 1;														
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
	set datefirst 1;
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
	set datefirst 1; -- needs to be done everywhere
	begin try
		if(@summaryCreated is not null)
		begin
		-- determine if absence
			exec determineAbsence @lastShift, @absenceType, @summaryCreated, @lastDate, @lastRecId, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				print 'Error determining absence absenceChecker 1: ' + @errMsg;
				throw 50070, @errMsg, 7;
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
				throw 50080, @errMsg, 8;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
-- this is an initializer function called from trigger, which is called on update automatically
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
	set datefirst 1;
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
-- auto updater trigger
alter trigger attendance.summaryUpdateSubroutine
	on attendance.attendance_record
		for update
as
	declare @insDate date;
	declare @ulogin varchar(40);
	declare @hours_worked_day real;
	declare @lastRecId int;
	declare @errMsg varchar(255);
	declare @logTime time;

	set @insDate = (select top 1 [day] from inserted);
	set @ulogin = (select top 1 userlogin from inserted);
	set @hours_worked_day = (select top 1 hours_worked_day from inserted);
	set @lastRecId = (select top 1 record_id from inserted);

	if((select top 1 until from inserted) is not null) -- if null then it could be an update of arrival
	begin

		if((select top 1 flag from #update_flag)=0)
		begin
			set @logTime = (select top 1 convert(time, rcl.change_timestamp, 101) from logs.record_change_log rcl
								join logs.records_changes as rc on rc.log_id=rcl.log_id
								join attendance.attendance_record as ar on ar.record_id=rc.record_id
								where ar.record_id=@lastRecId);
			if(abs(datediff(second, convert(time, getdate(), 101), @logTime))<=180)
			begin
				exec summaryUpdater @ulogin, @insDate, @hours_worked_day, @lastRecId, @errMsg=@errMsg;
			end;
			else
			begin
				select 'Cannot rewrite the attendance record';
				throw 50011, 'Cannot rewrite the attendance record', 1;
			end;
		end;
		else
		begin
			exec summaryUpdater @ulogin, @insDate, @hours_worked_day, @lastRecId, @errMsg=@errMsg;
		end;
	end;
	if(@errMsg is not null)
	begin
		;
		throw 50012, @errMsg, 1;
	end;
go
