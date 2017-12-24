--use MI_Florians_Patrik_Cvicna;
--go
-- 6.1
create table skola.archiv_znamek(
	id_archiv_znamek int primary key identity,
	id_ucitel int foreign key references skola.ucitel(id_ucitel),
	id_student int foreign key references skola.student(id_student),
	id_predmet int foreign key references skola.predmet(id_predmet),
	datum datetime,
	rozdil int
);
go
alter trigger skola.zmena_znamok
	on skola.znamka
		for update
		as
			insert into skola.archiv_znamek(id_ucitel, id_student, id_predmet, datum, rozdil)
			select i.id_ucitel, i.id_student, i.id_predmet, getdate(), abs(d.body - i.body) 
			from deleted as d, inserted as i;
			--select * from skola.znamka;
			--select * from deleted;
			--select * from inserted;
			--select * from skola.znamka;
			--select * from skola.archiv_znamek;
go
begin tran t
	update skola.znamka set body = 28 where id_student = 1  and id_predmet=1;
rollback tran t
go
--6.2
alter trigger skola.mazanie_znamky
on skola.znamka
for delete
	as 
	--select * from skola.archiv_znamek;
	delete from skola.archiv_znamek
	where id_student = (select top 1 id_student from deleted) and id_predmet=(select top 1 id_predmet from deleted) and 
			id_ucitel = (select top 1 id_ucitel from deleted);
	--select * from skola.archiv_znamek;
	--select * from skola.znamka;
go
begin tran t1
	select * from skola.archiv_znamek;
	update skola.znamka set body = 28 where id_student = 1  and id_predmet=1;
	select * from skola.archiv_znamek;
	select * from skola.znamka;
	delete from skola.znamka where id_student=1 and id_predmet=1 and id_ucitel = 3;
	select * from skola.archiv_znamek;
	select * from skola.znamka;
rollback tran t1
go
--6.3
create view pohlad_zmien
as 
select u.jmeno as [Jméno učitele], u.prijmeni [Přijmení učitele], st.jmeno[Jméno studenta], st.prijmeni [Příjmení studenta], 
		p.nazev as [Název předmětu], arch.rozdil [Změna počtu bodů] 
	from skola.archiv_znamek as arch join skola.student as st 
		on arch.id_student=st.id_student join skola.ucitel as u on
			u.id_ucitel=arch.id_ucitel join skola.predmet as p on
			p.id_predmet=arch.id_predmet;
go
begin tran t2
	select * from pohlad_zmien;
	update skola.znamka set body = 28 where id_student = 1  and id_predmet=1;
	update skola.znamka set body = 77 where id_student = 1  and id_predmet=2;
	select * from pohlad_zmien;
	delete from skola.znamka where id_student=1 and id_predmet=1 and id_ucitel = 3;
	select * from pohlad_zmien;
rollback tran t2
go
-- 6.4
create table skola.absolventi(
	id_student int foreign key references skola.student(id_student),
	id_predmet int foreign key references skola.predmet(id_predmet),
	constraint PK_absolventi primary key(id_student, id_predmet)
);
go
create trigger absolvoval
	on skola.znamka
		for update, insert
		as 
		insert into skola.absolventi(id_student, id_predmet) 
		select top 1 i.id_student, i.id_predmet from inserted as i
		where i.body>=49;
go
begin tran t3
	select * from skola.absolventi;
	update skola.znamka set body = 77 where id_student = 1  and id_predmet=2;
	select * from skola.absolventi;
	insert into skola.znamka(id_student, id_predmet, id_ucitel, body) values(1, 3, 3, 88);
	select * from skola.absolventi;
	select * from skola.znamka;
rollback tran t3
go
-- 7 
create table skola.odchylky_znamek(
	id_predmet int foreign key references skola.predmet(id_predmet),
	id_student int foreign key references skola.student(id_student),
	odchylka int,
	constraint PK_odchylky_znamek primary key(id_predmet, id_student)
);
go
alter proc spocitej_odchylky
@predmet as int,
@student as int
as
declare @priemer as int;
declare @idPredmet as int;
declare @idStudent as int;
declare kurzor cursor scroll for select id_predmet, id_student from skola.odchylky_znamek;-- where id_predmet=@predmet and id_student=@student;

open kurzor
fetch last from kurzor into @idPredmet, @idStudent;
set @priemer = (select avg(z.body) from skola.znamka as z where z.id_predmet=@predmet group by z.id_predmet);
--select @priemer as  priemer;
--where z.id_predmet=@predmet group by z.id_predmet);

	if ((not @idPredmet is null) and (not @idStudent is null))
	begin
		delete from skola.odchylky_znamek where current of kurzor; --mazat ten jeden stary
		insert into skola.odchylky_znamek(id_predmet, id_student, odchylka) 
		values(
		 @predmet, @student, abs(@priemer - (select top 1 body from skola.znamka where id_predmet=@predmet and id_student=@student))
		 ); -- vlozit ten jeden novy
	end;
	else 
	begin 
		insert into skola.odchylky_znamek(id_predmet, id_student, odchylka) 
		values(
		 @predmet, @student, abs(@priemer - (select top 1 body from skola.znamka where id_predmet=@predmet and id_student=@student))
		 );
	end;
	close kurzor;
	deallocate kurzor;
go
create view v_odchylky_znamek
as
	select s.jmeno as [jméno], s.prijmeni as [přijmení], p.nazev as [název], o.odchylka as [odchylka] 
		from skola.odchylky_znamek as o
			join skola.predmet as p on p.id_predmet = o.id_predmet
			join skola.student as s on s.id_student = o.id_student;
go
begin tran t4
	select * from skola.znamka;
	select * from v_odchylky_znamek;
	exec dbo.spocitej_odchylky 1, 1;
	select * from v_odchylky_znamek;
	exec dbo.spocitej_odchylky 2, 1;
	select * from v_odchylky_znamek;
rollback tran t4
--debug
--declare @objName varchar(25)
--set @objName = 'zmena_znamok'
--select objectproperty(object_id(@objName), 'isTrigger') isTrigger
--       ,objectproperty(object_id(@objName), 'ownerid') ownerID;

--select * from sysobjects where name = 'zmena_znamok'
