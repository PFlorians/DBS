-- script should containt only trigger and procedures used for value calculation
-- this procedure determines whether an emergency was in progress
use master
use attendance_dev
create proc determineEmergency
@hours_worked_day real,
@recId int,
@absenceType varchar(4),
@lastShift varchar(8),
@summaryId int,
@lastDate date,
@updateSummaryFlag bit=0,
@emergencyFlag bit output,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		declare @monthlyHours real;
		declare @emergencyPresent bit;
		declare @lastInsertedValue real;-- in case this is an update this value needs to be updated and subtracted from summary
		declare @updatedId int; -- used only in case this is an update

		set @lastInsertedValue = 0.0;
		set @emergencyPresent = 0;
		set @emergencyFlag = 0;
		if((@hours_worked_day > 0 )and (@absenceType is null) and (@lastShift like 'VOLN'))
		begin
			if(@updateSummaryFlag = 1) --need to subtract last inserted value
			begin
				set @lastInsertedValue = (select top 1 bonus_hours from attendance.summary_bonuses
											where record_id=@recId and (bonus_id = '0300' or bonus_id = '0301'));
				set @updatedId = (select top 1 id from attendance.summary_bonuses
											where record_id=@recId and (bonus_id = '0300' or bonus_id = '0301'));
				if(datepart(WEEKDAY, @lastDate)>=6 or (@lastDate in (select [date] from attendance.public_holidays)))
				begin
					update attendance.summary_bonuses
						set bonus_id='0301', record_id = @recId, [day]=@lastDate,
								bonus_hours=@hours_worked_day*(select top 1 [% bonus]/100.0
																from attendance.bonus
																where bonus_id like '0301')
						where id=@updatedId;
					set @emergencyPresent = 1; --indicates that emergency was present it is safe to update
				end;
				else if(datepart(WEEKDAY, @lastDate)<6)
				begin
					update attendance.summary_bonuses
						set bonus_id='0300', record_id = @recId, [day]=@lastDate,
								bonus_hours=@hours_worked_day*(select top 1 [% bonus]/100.0
																from attendance.bonus
																where bonus_id like '0300')
						where id=@updatedId;
					set @emergencyPresent = 1;
				end;
			end;--update scenario ends here
			else--regular case begins here
			begin
				if(datepart(WEEKDAY, @lastDate)>=6 or (@lastDate in (select [date] from attendance.public_holidays)))
				begin
					insert into attendance.summary_bonuses(bonus_id, record_id, day, bonus_hours)
						values('0301', @recId, @lastDate, @hours_worked_day*(select top 1 [% bonus]/100.0
																					from attendance.bonus
																					where bonus_id like '0301'));
					set @emergencyPresent = 1; --indicates that emergency was present it is safe to update
				end;
				else if(datepart(WEEKDAY, @lastDate)<6)
				begin
					insert into attendance.summary_bonuses(bonus_id, record_id, day, bonus_hours)
						values('0300', @recId, @lastDate, @hours_worked_day*(select top 1 [% bonus]/100.0
																					from attendance.bonus
																					where bonus_id like '0300'));
					set @emergencyPresent = 1;
				end;
			end;
			if(@emergencyPresent <> 0) -- safe to update if this was an emergency call
			begin
				set @monthlyHours = (select top 1 bonus_hours_month from attendance.summary
									where summary_id=@summaryId);
				if(@monthlyHours is null)
				begin
					set @monthlyHours = 0.0;
				end;
				if(@lastInsertedValue is null)
				begin
					set @lastInsertedValue = 0.0;
				end;
				if((select top 1 bonus_hours from attendance.summary_bonuses
													where id=(IDENT_CURRENT('attendance.summary_bonuses'))) is null)
				begin
					if(@updateSummaryFlag = 1) -- subtract previous value only if this is a corrective update
					begin
						set @monthlyHours = @monthlyHours - @lastInsertedValue + 0;
					end;
				end;
				else
				begin
					if(@updateSummaryFlag = 1)
					begin
						set @monthlyHours = @monthlyHours - @lastInsertedValue
								 + (select top 1 bonus_hours from attendance.summary_bonuses
														where id=(IDENT_CURRENT('attendance.summary_bonuses')));
					end;
					else
					begin
						set @monthlyHours = @monthlyHours + (select top 1 bonus_hours from attendance.summary_bonuses
														where id=(IDENT_CURRENT('attendance.summary_bonuses')));
					end;
				end;
				-- update summary -> bonuses
				update attendance.summary
					set bonus_hours_month = @monthlyHours
					where summary_id = @summaryId;
				-- will signalize that an emergency had happened to procedure outside
				set @emergencyFlag=@emergencyPresent;
				exec summarySnapshot @summaryId=@summaryId, @bonus_hours_month=@monthlyHours, @errMsg=@errMsg;
				if(@errMsg is not null)
				begin
					;
					throw 50201, @errMsg, 1;
				end;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 50202, @errMsg, 1;
	end catch;
go
create proc determineOvertime
@hours_worked_day real,
@recId int,
@expectedWorkTime real,
@lastShift varchar(8),
@lastDate date,
@summaryId int,
@updateSummaryFlag bit = 0,
@errMsg varchar(255) output,
@overtimePresent real output
as
	set datefirst 1;
	begin try
		declare @overtime real;
		declare @monthlyHours real;
		declare @lastInsertedValue real;
		declare @lastInsertedId int;

		set @lastInsertedValue = 0.0;
		set @overtimePresent = 0.0;
		if(@updateSummaryFlag = 1)
		begin
			set @lastInsertedValue = (select top 1 bonus_hours from attendance.summary_bonuses
										where record_id=@recId and (bonus_id='0161' or bonus_id='0160'));
			set @lastInsertedId = (select top 1 id from attendance.summary_bonuses
										where record_id=@recId and (bonus_id='0161' or bonus_id='0160'));
			--update branch, no insertion works over existing data
			if(((@hours_worked_day - @expectedWorkTime) > 0)
			and (datepart(WEEKDAY, @lastDate) >= 6)
			and (@lastDate not in (select [date] from attendance.public_holidays))
			and (@lastShift not like 'VOLN'))
			begin
				set @overtime = 50;
				set @overtimePresent = (@hours_worked_day - @expectedWorkTime);
				update attendance.summary_bonuses
					set bonus_id='0161', record_id = @recId, [day]=@lastDate,
						bonus_hours=((@overtime/100.0)*(@hours_worked_day - @expectedWorkTime))
					where id=@lastInsertedId;
			end;
			else if(((@hours_worked_day - @expectedWorkTime) > 0) and
			(datepart(WEEKDAY, @lastDate) < 6)
			and (@lastDate not in (select [date] from attendance.public_holidays))
			and	(@lastShift not like 'VOLN'))
			begin
				set @overtime = 25;
				set @overtimePresent = (@hours_worked_day - @expectedWorkTime);
				update attendance.summary_bonuses
					set bonus_id='0160', record_id = @recId, [day]=@lastDate,
						bonus_hours=((@overtime/100.0)*(@hours_worked_day - @expectedWorkTime))
					where id=@lastInsertedId;
			end;
		end;--update branch ends here
		else -- regular flow begins here
		begin
			if(((@hours_worked_day - @expectedWorkTime) > 0)
			and ((datepart(WEEKDAY, @lastDate) >= 6))
			and (@lastDate not in (select [date] from attendance.public_holidays))
			and (@lastShift not like 'VOLN'))
			begin
				set @overtime = 50;
				set @overtimePresent = (@hours_worked_day - @expectedWorkTime);
				insert into attendance.summary_bonuses(bonus_id, record_id, day, bonus_hours)
					values ('0161', @recId, @lastDate, (@overtime/100.0)*(@hours_worked_day - @expectedWorkTime));
			end;
			else if(((@hours_worked_day - @expectedWorkTime) > 0) and
			(datepart(WEEKDAY, @lastDate) < 6) 
			and (@lastDate not in (select [date] from attendance.public_holidays))
			and (@lastShift not like 'VOLN'))
			begin
				set @overtime = 25;
				set @overtimePresent = (@hours_worked_day - @expectedWorkTime);
				insert into attendance.summary_bonuses(bonus_id, record_id, day, bonus_hours)
					values ('0160', @recId, @lastDate, (@overtime/100.0)*(@hours_worked_day - @expectedWorkTime));
			end;
		end;

		-- update to increase the overall value
		if(@overtimePresent > 0) --safe to update if overtime was achieved
		begin
			set @monthlyHours = (select top 1 bonus_hours_month from attendance.summary
								where summary_id=@summaryId);
			if(@monthlyHours is null)
			begin
				set @monthlyHours = 0.0;
			end;
			if(@lastInsertedValue is null)
			begin
				set @lastInsertedValue = 0.0;
			end;
			if((select top 1 bonus_hours from attendance.summary_bonuses
													where id=(IDENT_CURRENT('attendance.summary_bonuses'))) is null)
			begin
				if(@updateSummaryFlag = 1) -- subtract only if update
				begin
					set @monthlyHours = @monthlyHours - @lastInsertedValue + 0;
				end;
			end;
			else
			begin
				if(@updateSummaryFlag = 1) -- subtract only if update
				begin
					set @monthlyHours = @monthlyHours - @lastInsertedValue
									+ (select top 1 bonus_hours from attendance.summary_bonuses
										where id=(IDENT_CURRENT('attendance.summary_bonuses')));
				end;
				else
				begin
					set @monthlyHours = @monthlyHours + (select top 1 bonus_hours from attendance.summary_bonuses
										where id=(IDENT_CURRENT('attendance.summary_bonuses')));
				end;
			end;
			-- update summary -> bonuses
			update attendance.summary
				set bonus_hours_month = @monthlyHours
				where summary_id = @summaryId;
			exec summarySnapshot @summaryId=@summaryId, @bonus_hours_month=@monthlyHours, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				;
				throw 50201, @errMsg, 1;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 50203, @errMsg, 1;
	end catch;
go
create proc determinePublicHoliday
@lastShift varchar(8),
@recId int,
@expectedWorkTime real,
@lastDate date,
@summaryId int,
@hours_worked_day real,
@updateSummaryFlag bit = 0,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		declare @monthlyHours real;
		declare @lastInsertedValue real;
		declare @lastInsertedId int;
		declare @publicHolidayId int;
		declare @publicHolidayPositive bit; -- at the end of this procedure is a bonus update, this flag justifies that update

		set @lastInsertedValue = 0.0;
		set @publicHolidayPositive = 0;
		if(@updateSummaryFlag = 1)
		begin
			set @lastInsertedValue = (select top 1 bonus_hours from attendance.summary_bonuses
										where record_id=@recId and (bonus_id='0161' or bonus_id='0160'));
			set @lastInsertedId = (select top 1 id from attendance.summary_bonuses
										where record_id=@recId and (bonus_id='0161' or bonus_id='0160'));
			if(((@hours_worked_day - @expectedWorkTime) > 0) and
			(@lastDate in (select [date] from attendance.public_holidays)))
			begin
				set @publicHolidayId = (select top 1 id from attendance.public_holidays where
										[date] = @lastDate);
				update attendance.summary_bonuses
					set record_id = @recId, [day]=@lastDate,
					bonus_hours = @hours_worked_day * (select top 1 [% bonus]/100.0 from attendance.bonus where bonus_id like '0140')
					where id = @lastInsertedId;
				set @publicHolidayPositive = 1;
			end;
		end;
		else
		begin
			if(((@hours_worked_day - @expectedWorkTime) > 0) and
			(@lastDate in (select [date] from attendance.public_holidays)))
			begin
				set @publicHolidayId = (select top 1 id from attendance.public_holidays where
										[date] = @lastDate);
				insert into attendance.summary_bonuses(bonus_id, record_id, [day], bonus_hours)
				values ('0140', @recId, @lastDate, @hours_worked_day*(select top 1 [% bonus]/100.0 from
																			attendance.bonus
																			where bonus_id like '0140'));
				insert into attendance.summary_public_holidays(record_id, public_holiday_id)
				values(@recId, @publicHolidayId);
				set @publicHolidayPositive = 1;
			end;
		end;
		if(@publicHolidayPositive = 1)
		begin
			-- calculate summary statistics in this code segment
			set @monthlyHours = (select top 1 bonus_hours_month from attendance.summary
								where summary_id=@summaryId);
			if(@monthlyHours is null)
			begin
				set @monthlyHours = 0.0;
			end;
			if(@lastInsertedValue is null)
			begin
				set @lastInsertedValue = 0.0;
			end;
			if((select top 1 bonus_hours from attendance.summary_bonuses
													where id=(IDENT_CURRENT('attendance.summary_bonuses'))) is null)
			begin
				if(@updateSummaryFlag = 1) -- subtract only if update
				begin
					set @monthlyHours = @monthlyHours - @lastInsertedValue + 0;
				end;
			end;
			else
			begin
				if(@updateSummaryFlag = 1) -- subtract only if update
				begin
					set @monthlyHours = @monthlyHours - @lastInsertedValue
									+ (select top 1 bonus_hours from attendance.summary_bonuses
										where id=(IDENT_CURRENT('attendance.summary_bonuses')));
				end;
				else
				begin
					set @monthlyHours = @monthlyHours + (select top 1 bonus_hours from attendance.summary_bonuses
										where id=(IDENT_CURRENT('attendance.summary_bonuses')));
				end;
			end;
			-- update summary -> bonuses
			update attendance.summary
				set bonus_hours_month = @monthlyHours
				where summary_id = @summaryId;
			-- snapshot to see what happened
			exec summarySnapshot @summaryId=@summaryId, @bonus_hours_month=@monthlyHours, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				;
				throw 55201, @errMsg, 1;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 55001, @errMsg, 1;
	end catch;
go
create proc determineBonus
@lastShift varchar(8),
@recId int,
@lastDate date,
@summaryId int,
@hours_worked_day real,
@updateSummaryFlag bit = 0,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		declare @monthlyHours real;
		declare @lastInsertedValue real;
		declare @lastInsertedId int;
		declare @bonusPresentFlag bit; -- determines whether an update should be performed at the end

		set @lastInsertedValue = 0.0;
		set @bonusPresentFlag =0;
		if(@updateSummaryFlag = 1)
		begin
			set @lastInsertedValue = (select top 1 bonus_hours from attendance.summary_bonuses
										where record_id=@recId and
										(bonus_id='0110' or bonus_id='0123' or
											bonus_id = '0130' or bonus_id='0140'));
			set @lastInsertedId = (select top 1 id from attendance.summary_bonuses
										where record_id=@recId and
										(bonus_id='0110' or bonus_id='0123' or
											bonus_id = '0130' or bonus_id='0140'));
			if((@lastShift like '[NO]%') or (DATEPART(weekday, @lastDate) >= 6))
			begin
			update attendance.summary_bonuses
				set bonus_id=(case
							when @lastShift like 'O%' then '0110'
							when @lastShift like 'N%' then '0123'
							when ((DATEPART(weekday, convert(date, @lastDate, 101)) = 6) or
								(DATEPART(weekday, convert(date, @lastDate, 101)) = 7)) then '0130'
							when (convert(date, @lastDate, 101) in (select [date] from attendance.public_holidays))
								then '0140'
						end), record_id=@recId, [day]=@lastDate,
						bonus_hours=(case
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
						end)
				where id=@lastInsertedId;
				set @bonusPresentFlag =1;
			end;
		end; --end of update flow
		else -- regular flow begin here
		begin
			if((@lastShift like '[NO]%') or (DATEPART(weekday, @lastDate) >= 6))
			begin
				insert into attendance.summary_bonuses(bonus_id, record_id, day, bonus_hours)
					select (case
								when @lastShift like 'O%' then '0110'
								when @lastShift like 'N%' then '0123'
								when ((DATEPART(weekday, convert(date, @lastDate, 101)) = 6) or
									(DATEPART(weekday, convert(date, @lastDate, 101)) = 7)) then '0130'
								when (convert(date, @lastDate, 101) in (select [date] from attendance.public_holidays))
									then '0140'
							end) as bonus_id, @recId as record_id, @lastDate as day,
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
				set @bonusPresentFlag = 1;
			end;
		end;
		if(@bonusPresentFlag = 1)
		begin
			set @monthlyHours = (select top 1 bonus_hours_month from attendance.summary
										where summary_id=@summaryId);
			if(@monthlyHours is null)
			begin
				set @monthlyHours = 0.0;
			end;
			if(@lastInsertedValue is null)
			begin
				set @lastInsertedValue = 0.0;
			end;
			if((select top 1 bonus_hours from attendance.summary_bonuses
											where id=(IDENT_CURRENT('attendance.summary_bonuses'))) is null)
			begin
				if(@updateSummaryFlag = 1) -- only if this is a corrective update of some sort
				begin
					set @monthlyHours = @monthlyHours - @lastInsertedValue + 0;
				end;
			end;
			else
			begin
				if(@updateSummaryFlag = 1)
				begin
					set @monthlyHours = @monthlyHours - @lastInsertedValue
									 + (select top 1 bonus_hours from attendance.summary_bonuses
											where id=(IDENT_CURRENT('attendance.summary_bonuses')));
				end;
				else
				begin
					set @monthlyHours = @monthlyHours + (select top 1 bonus_hours from attendance.summary_bonuses
											where id=(IDENT_CURRENT('attendance.summary_bonuses')));
				end
			end;
			-- update summary -> bonuses
			update attendance.summary
				set bonus_hours_month = @monthlyHours
				where summary_id = @summaryId;
			exec summarySnapshot @summaryId=@summaryId, @bonus_hours_month=@monthlyHours, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				;
				throw 50201, @errMsg, 1;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 50222, @errMsg, 1;
	end catch;
go
alter proc determineAbsence
@lastShift varchar(8),
@recId int,
@absenceType varchar(4),
@absenceLength real,
@summaryId int,
@lastDate date,
@updateAbsenceSummaryFlag bit=0,
@errMsg varchar(255) output
as
	set datefirst 1;
	begin try
		declare @monthlyHours real;
		--declare @absenceLength real;
		declare @previousAbsenceLength real;

		set @previousAbsenceLength = 0.0;
		if((@lastShift like 'VOLN') and (@absenceType is not null))
		begin
			-- in this case it is the same as worked hours
			--set @absenceLength = (select top 1 hours_worked_day from attendance.attendance_record where record_id=@recId)
			set @previousAbsenceLength = (select top 1 hours_absent from attendance.summary_absence where record_id=@recId order by id desc);
			update attendance.summary_absence
					set absence_type=@absenceType, record_id=@recId, day_of_absence=@lastDate, hours_absent=@absenceLength
					where record_id=@recId; 

			--update overall absence
			set @monthlyHours = (select top 1 hours_absent_month from attendance.summary
								where summary_id=@summaryId);
			-- we need to subtract previous value in case of update < 3 mins, otherwise we get incorrect
			-- statistics in summary
			if(@monthlyHours is not null and @previousAbsenceLength is not null)
			begin
				if(@updateAbsenceSummaryFlag = 1) --Am I updating the record?
				begin
					set @monthlyHours = @monthlyHours - @previousAbsenceLength + @absenceLength;
				end;
				else--if not then I shouldn't subtract anything
				begin
					set @monthlyHours = @monthlyHours + @absenceLength;
				end;
			end;
			else
			begin
				if(@monthlyHours is null)
				begin
					set @monthlyHours = 0.0;
				end;
				if(@previousAbsenceLength is null)
				begin
					set @previousAbsenceLength = 0.0;
				end
				if(@updateAbsenceSummaryFlag = 1)
				begin
					set @monthlyHours = @monthlyHours - @previousAbsenceLength + @absenceLength;
				end;
				else
				begin
					set @monthlyHours = @monthlyHours + @absenceLength;
				end;
			end;

			update attendance.summary
				set hours_absent_month = @monthlyHours
				where summary_id = @summaryId;
			exec summarySnapshot @summaryId=@summaryId, @hours_absent_month=@monthlyHours, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				;
				throw 50201, @errMsg, 1;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 51007, @errMsg, 1;
	end catch;
go
create proc fullCheck
@ulogin varchar(40),
@recId int,
@lastDate date,
@hours_worked_day real,
@summaryCreated int,
@lastShift varchar(8),
@expectedWorkTime real,
@absenceType varchar(4),
@updateSummaryFlag bit=0, -- is this an update?
@errMsg varchar(255) output
as
	declare @monthlyHours real;
	declare @overtimePresent real;
	declare @snapshotHoursInserted real;
	declare @emergencyPresent bit;

	set datefirst 1;
	set @overtimePresent =0.0;
	set @snapshotHoursInserted = 0.0;
	set @emergencyPresent = 0;
	begin try
		if(@summaryCreated is not null)
		begin
			-- determine if emergency
			if(@updateSummaryFlag = 1)
			begin
				exec determineEmergency @hours_worked_day, @recId, @absenceType, @lastShift, @summaryCreated, @lastDate, 1, @emergencyPresent out, @errMsg out;
			end;
			else
			begin
				exec determineEmergency @hours_worked_day, @recId, @absenceType, @lastShift, @summaryCreated, @lastDate, 0, @emergencyPresent out, @errMsg out;
			end;
			if(@errMsg is not null)
			begin
				print 'Error determining emergency: ' + @errMsg;
				throw 51111, @errMsg, 1;
			end;
			else
			begin
				-- determine if employee should be paid overtime
				if(@updateSummaryFlag = 1)
				begin
					exec determineOvertime @hours_worked_day, @recId, @expectedWorkTime, @lastShift, @lastDate, @summaryCreated, 1, @errMsg out, @overtimePresent out;
				end;
				else
				begin
					exec determineOvertime @hours_worked_day, @recId, @expectedWorkTime, @lastShift, @lastDate, @summaryCreated, 0, @errMsg out, @overtimePresent out;
				end;
				set @hours_worked_day = @hours_worked_day - @overtimePresent;-- this can only be done here not earlier not later
				if(@errMsg is not null)
				begin
					print 'Error determining overtime: ' + @errMsg;
					throw 51112, @errMsg, 2;
				end;
				-- find out if this is a public holiday worker case
				if(@updateSummaryFlag = 1)
				begin
					exec determinePublicHoliday @lastShift, @recId, @expectedWorkTime, @lastDate, @summaryCreated, @hours_worked_day, 1, @errMsg out;
				end;
				else
				begin
					exec determinePublicHoliday @lastShift, @recId, @expectedWorkTime, @lastDate, @summaryCreated, @hours_worked_day, 0, @errMsg out;
				end;
				if(@errMsg is not null)
				begin
					set @errMsg = 'Error determining public holiday: ' + @errMsg;
					throw 51117, @errMsg, 7;
				end;
			end;
			--emergency is also a type of bonus and it takes precedence if it happened
			if(@emergencyPresent = 0)
			begin
				-- determine any other bonus
				if(@updateSummaryFlag = 1)
				begin
					exec determineBonus @lastShift, @recId, @lastDate, @summaryCreated, @hours_worked_day, 1, @errMsg=@errMsg;
				end;
				else
				begin
					exec determineBonus @lastShift, @recId, @lastDate, @summaryCreated, @hours_worked_day, 0, @errMsg=@errMsg;
				end;
				if(@errMsg is not null)
				begin
					print 'Error determining bonuses: ' + @errMsg;
					throw 51113, @errMsg, 3;
				end;
			end;
			if(@updateSummaryFlag = 1)
			begin
				set @snapshotHoursInserted = (select top 1 hours_worked_inserted
												 from logs.summary_state_snapshot
												where summary_id=@summaryCreated and
										(cast(convert(datetime, convert(date, [timestamp])) as float) -
										cast(convert(datetime, @lastDate) as float)) = 0
										order by id desc);
			end;
			set @monthlyHours = (select top 1 hours_worked_month from attendance.summary
								where summary_id=@summaryCreated);
			if(@monthlyHours is null)
			begin
				set @monthlyHours = 0.0;
			end;
			if(@snapshotHoursInserted is null)
			begin
				set @snapshotHoursInserted = 0.0;
			end;
			if(@updateSummaryFlag = 1) --only do this if this is an update
			begin
				set @monthlyHours = @monthlyHours - @snapshotHoursInserted + @hours_worked_day;
			end;
			else if(@monthlyHours <> @hours_worked_day)
			begin
				set @monthlyHours = @monthlyHours + @hours_worked_day;
			end;

			update attendance.summary
				set hours_worked_month = @monthlyHours
				where summary_id = @summaryCreated;
			--call snapshotting logger
			exec summarySnapshot @summaryId=@summaryCreated, @hours_worked_month=@monthlyHours, @hours_worked_inserted=@hours_worked_day, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				set @errMsg = 'Full check error creating snapshot: ' + @errMsg;
				throw 51119, @errMsg, 9;
			end;
		end; -- if summary existed flow ends here
		else -- if summary doesn't yet exists, flow starts here
		begin
			insert into attendance.summary(record_id, hours_worked_month, hours_absent_month, bonus_hours_month)
				values(@recId, @hours_worked_day, 0, 0);
			set @summaryCreated = IDENT_CURRENT('attendance.summary');
			-- determine if emergency
			if(@updateSummaryFlag = 1)
			begin
				exec determineEmergency @hours_worked_day, @recId, @absenceType, @lastShift, @summaryCreated, @lastDate, 1, @emergencyPresent out, @errMsg out;
			end;
			else
			begin
				exec determineEmergency @hours_worked_day, @recId, @absenceType, @lastShift, @summaryCreated, @lastDate, 0, @emergencyPresent out, @errMsg out;
			end;
			if(@errMsg is not null)
			begin
				print 'Error determining emergency 2: ' + @errMsg;
				throw 51114, @errMsg, 4;
			end;
			else
			begin
				-- determine if employee should be paid overtime
				if(@updateSummaryFlag = 1)
				begin
					exec determineOvertime @hours_worked_day, @recId, @expectedWorkTime, @lastShift, @lastDate, @summaryCreated, 1, @errMsg out, @overtimePresent out;
				end;
				else
				begin
					exec determineOvertime @hours_worked_day, @recId, @expectedWorkTime, @lastShift, @lastDate, @summaryCreated, 0, @errMsg out, @overtimePresent out;
				end;
				set @hours_worked_day = @hours_worked_day - @overtimePresent; -- this can only be done here not earlier not later
				if(@errMsg is not null)
				begin
					print 'Error determining overtime 2: ' + @errMsg;
					throw 51115, @errMsg, 5;
				end;
				if(@updateSummaryFlag = 1)
				begin
					exec determinePublicHoliday @lastShift, @recId, @expectedWorkTime, @lastDate, @summaryCreated, @hours_worked_day, 1, @errMsg out;
				end;
				else
				begin
					exec determinePublicHoliday @lastShift, @recId, @expectedWorkTime, @lastDate, @summaryCreated, @hours_worked_day, 0, @errMsg out;
				end;
				if(@errMsg is not null)
				begin
					set @errMsg = 'Error determining public holiday fresh creation of summary: ' + @errMsg;
					throw 51118, @errMsg, 8;
				end;
			end;
			--emergency has precedence
			if(@emergencyPresent = 0)
			begin
				-- determine any other bonus
				if(@updateSummaryFlag = 1)
				begin
					exec determineBonus @lastShift, @recId, @lastDate, @summaryCreated, @hours_worked_day, 1, @errMsg=@errMsg;
				end;
				else
				begin
					exec determineBonus @lastShift, @recId, @lastDate, @summaryCreated, @hours_worked_day, 0, @errMsg=@errMsg;
				end;
				if(@errMsg is not null)
				begin
					print 'Error determining bonuses 2: ' + @errMsg;
					throw 51116, @errMsg, 5;
				end;
			end;
			-- updating the summary here
			if(@updateSummaryFlag = 1)
			begin
				set @snapshotHoursInserted = (select top 1 hours_worked_inserted
												 from logs.summary_state_snapshot
												where summary_id=@summaryCreated and
										(cast(convert(datetime, convert(date, [timestamp])) as float) -
										cast(convert(datetime, @lastDate) as float)) = 0
										order by id desc);
			end;

			set @monthlyHours = (select top 1 hours_worked_month from attendance.summary
								where summary_id=@summaryCreated);
				-- update summary -> bonuses
				-- no point in further calculation, since no summary previously existed
			if(@monthlyHours is null)
			begin
				set @monthlyHours = 0.0;
			end;
			if(@snapshotHoursInserted is null)
			begin
				set @snapshotHoursInserted = 0.0;
			end;
			update attendance.summary
				set hours_worked_month = @monthlyHours
				where summary_id = @summaryCreated;
			--call snapshotting logger
			exec summarySnapshot @summaryId=@summaryCreated, @hours_worked_month=@monthlyHours, @hours_worked_inserted=@hours_worked_day, @errMsg=@errMsg;
			if(@errMsg is not null)
			begin
				set @errMsg = 'Full check error creating snapshot: ' + @errMsg;
				throw 51119, @errMsg, 9;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 51120, @errMsg, 1;
	end catch;
go
create proc absenceChecker
@ulogin varchar(40),
@recId int,
@lastDate date,
@hours_worked_day real,
@summaryCreated int,
@lastShift varchar(8),
@expectedWorkTime real,
@absenceType varchar(4),
@updateAbsenceSummaryFlag bit=0,
@errMsg varchar(255) output
as
	set datefirst 1; -- needs to be done everywhere
	begin try
		if(@summaryCreated is not null)
		begin
		-- determine if absence
			if(@updateAbsenceSummaryFlag=1)
			begin
				exec determineAbsence @lastShift, @recId, @absenceType, @hours_worked_day, @summaryCreated, @lastDate, 1, @errMsg=@errMsg;
			end;
			else
			begin
				exec determineAbsence @lastShift, @recId, @absenceType, @hours_worked_day, @summaryCreated, @lastDate, 0, @errMsg=@errMsg;
			end;
			if(@errMsg is not null)
			begin
				print 'Error determining absence absenceChecker 1: ' + @errMsg;
				throw 50070, @errMsg, 7;
			end;
		end;
		else
		begin
			insert into attendance.summary(record_id, hours_worked_month, hours_absent_month, bonus_hours_month)
				values(@recId, @hours_worked_day, 0, 0);
			set @summaryCreated = IDENT_CURRENT('attendance.summary');
			if(@updateAbsenceSummaryFlag=1)
			begin
				exec determineAbsence @lastShift, @recId, @absenceType, @hours_worked_day, @summaryCreated, @lastDate, 1, @errMsg=@errMsg;
			end;
			else
			begin
				exec determineAbsence @lastShift, @recId, @absenceType, @hours_worked_day, @summaryCreated, @lastDate, 0, @errMsg=@errMsg;
			end;
			if(@errMsg is not null)
			begin
				print 'Error determining absence absenceChecker 2: ' + @errMsg;
				throw 50080, @errMsg, 8;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 51008, @errMsg, 1;
	end catch;
go
-- this is an initializer function called from trigger, which is called on update automatically
-- ulogin -> user login
-- lastDate -> insertion date
-- hours_worked_day -> how many hours the user worked per day/per shift in case this was a night shift
--
create proc summaryUpdater
@ulogin varchar(40),
@recId int,
@lastDate date,
@hours_worked_day real,
@updateAbsenceSummaryFlag bit=0, -- whether this is a regular insert or an update, otherwise there will be duplicities
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
		-- if so, no new shall be created, otherwise create a new one

		set @summaryCreated = (select top 1 asu.summary_id from attendance.attusr as au
			join attendance.attendance_record as ar on ar.userLogin = au.ulogin
			join attendance.summary as asu on asu.record_id=ar.record_id
			where ar.userLogin = @ulogin and (MONTH(@lastDate) = MONTH(ar.[day]))
			order by ar.record_id asc);

		set @lastShift = (select top 1 shifttype from attendance.recorded_shifts where record_id=@recId order by id desc);
		set @expectedWorkTime = (select top 1 planned_hours_work from attendance.shift where [type]=@lastShift);
		set @absenceType = (select top 1 absence_type from attendance.summary_absence
							where record_id=@recId order by id desc);

		-- in case we are dealing with public holiday we need to take change the code flow
		if(@lastDate in (select [date] from attendance.public_holidays))
		begin
			set @expectedWorkTime = 0.0;
		end;
		-- deciding whether this is an absence or not
		-- if yes, then there can be no bonuses, just record absence, thats it
		-- if something is a weekend, do nothing
		if(@expectedWorkTime = 0.0 and @hours_worked_day <> 0.0 and @lastShift like 'VOLN' and @absenceType not like '')
		begin
			if(@updateAbsenceSummaryFlag = 1)
			begin
				exec absenceChecker @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 1, @errMsg=@errMsg;
			end;
			else
			begin
				exec absenceChecker @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 0, @errMsg=@errMsg;
			end;
			if(@errMsg is not null)
			begin
				set @errMsg= 'Error determining absence summaryChecker: ' + @errMsg;
				throw 50123, @errMsg, 1;
			end;
		end;--highly likely an emergency
		else if(@expectedWorkTime = 0 and @hours_worked_day <> 0 and @lastShift like 'VOLN' and (@absenceType like '' or @absenceType is null))
		begin
			if(@updateAbsenceSummaryFlag = 1)
			begin
				exec fullCheck @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 1, @errMsg=@errMsg;
			end;
			else
			begin
				exec fullCheck @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 0, @errMsg=@errMsg;
			end;
			if(@errMsg is not null)
			begin
				set @errMsg = 'Error determining absence summaryChecker - fullCheck: ' + @errMsg;
				throw 50122, @errMsg, 1;
			end;
		end; --highly likely a public holiday
		else if(@expectedWorkTime = 0 and @hours_worked_day <> 0 and @lastShift not like 'VOLN' and (@absenceType like '' or @absenceType is null))
		begin
			if(@updateAbsenceSummaryFlag = 1)
			begin
				exec fullCheck @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 1, @errMsg=@errMsg;
			end;
			else
			begin
				exec fullCheck @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 0, @errMsg=@errMsg;
			end;
			if(@errMsg is not null)
			begin
				set @errMsg = 'Error determining absence summaryChecker - fullCheck: ' + @errMsg;
				throw 50121, @errMsg, 1;
			end;
		end;
		else if(@expectedWorkTime <> 0 and (@lastShift not like 'VOLN') and (@absenceType like '' or @absenceType is null))--could be regular work
		begin
			if(@updateAbsenceSummaryFlag = 1)
			begin
				exec fullCheck @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 1, @errMsg=@errMsg;
			end;
			else
			begin
				exec fullCheck @ulogin, @recId, @lastDate, @hours_worked_day, @summaryCreated, @lastShift, @expectedWorkTime, @absenceType, 0, @errMsg=@errMsg;
			end;
			if(@errMsg is not null)
			begin
				set @errMsg = 'Error determining absence summaryChecker - fullCheck: ' + @errMsg;
				throw 50124, @errMsg, 1;
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
		throw 50125, @errMsg, 2;
	end catch;
go
-- auto updater trigger
create trigger attendance.summaryUpdateSubroutine
	on attendance.attendance_record
		for update
as
	declare @insDate date;
	declare @ulogin varchar(40);
	declare @hours_worked_day real;
	declare @recId int;
	declare @errMsg varchar(255);
	declare @logTime time;
	declare @forceUpdate bit;

	set @insDate = (select top 1 [day] from inserted);
	set @ulogin = (select top 1 userlogin from inserted);
	set @hours_worked_day = (select top 1 hours_worked_day from inserted);
	set @recId = (select top 1 record_id from inserted);
	

	if((select top 1 until from inserted) is not null) -- if null then it could be an update of arrival
	begin
		if(OBJECT_ID('tempdb..#force_update_flag') is not null) -- indicates whether an update is to be done
		begin
			set @forceUpdate = (select top 1 flag from #force_update_flag);
		end;
		if((select top 1 flag from #update_flag)=0)
		begin
			set @logTime = (select top 1 convert(time, rcl.change_timestamp, 101) from logs.record_change_log rcl
								join logs.records_changes as rc on rc.log_id=rcl.log_id
								join attendance.attendance_record as ar on ar.record_id=rc.record_id
								where ar.record_id=@recId);
			if(abs(datediff(second, convert(time, getdate(), 101), @logTime))<=180 and @forceUpdate =0)
			begin
				exec summaryUpdater @ulogin, @recId, @insDate, @hours_worked_day, 1, @errMsg=@errMsg;
			end;
			else if(@forceUpdate = 1)
			begin
				exec summaryUpdater @ulogin, @recId, @insDate, @hours_worked_day, 0, @errMsg=@errMsg;
			end;
			else
			begin
				;
				throw 50011, 'Cannot rewrite the attendance record', 1;
			end;
		end;
		else
		begin
			exec summaryUpdater @ulogin, @recId, @insDate, @hours_worked_day, 0, @errMsg=@errMsg;
		end;
	end;
	if(@errMsg is not null)
	begin
		;
		throw 50012, @errMsg, 1;
	end;
go
