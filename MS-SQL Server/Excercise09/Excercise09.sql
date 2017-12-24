use MI_Florians_Patrik_MAIN;

-- 5.1
create table skola.student_zaloha(
	id_student int,
	jmeno varchar(255) sparse,
	prijmeni varchar(255) sparse
	);
go
create table skola.znamky_zaloha(
	id_student int,
	id_predmet int,
	body int
	);
go
alter table skola.student_zaloha alter column id_student int not null;
alter table skola.student_zaloha add constraint PK_stud_zal primary key(id_student);
go
alter table skola.znamky_zaloha alter column id_student int not null;
alter table skola.znamky_zaloha alter column id_predmet int not null;
alter table skola.znamky_zaloha add constraint PK_znamky_zal primary key(id_student, id_predmet);
go
-- 5.2
create proc smaz_studenta
@id int,
@jmeno varchar(20),
@prijmeni varchar(30)
as
	declare @i as int;
	declare	@j as int;
	if not (select id_student from skola.student where id_student=@id) is null
	begin
		set @i = (select top 1 z.id_predmet from skola.student as s
				join skola.znamka as z on s.id_student=z.id_student
				where s.prijmeni like @prijmeni and @id=z.id_student and s.jmeno like @jmeno
				order by z.id_predmet desc); -- najvyssie id je pocet cyklov
		set @j = 1; --id zacina od 1
		insert into skola.student_zaloha(id_student, jmeno, prijmeni) values
			(@id, @jmeno, @prijmeni);
		while @j<=@i 
		begin
			--select @j as j;
			insert into skola.znamky_zaloha(id_student, id_predmet, body)
			values (
					(select z.id_student from skola.student as s
						join skola.znamka as z on s.id_student=z.id_student
						where s.prijmeni like @prijmeni and @id=z.id_student and s.jmeno like @jmeno and z.id_predmet=@j
					), (select z.id_predmet from skola.student as s
						join skola.znamka as z on s.id_student=z.id_student
						where s.prijmeni like @prijmeni and @id=z.id_student and s.jmeno like @jmeno and z.id_predmet=@j
					),
					(select z.body from skola.student as s
						join skola.znamka as z on s.id_student=z.id_student
						where s.prijmeni like @prijmeni and @id=z.id_student and s.jmeno like @jmeno and z.id_predmet=@j
					)
					);
			set @j=@j+1;
		end;
	end;
	--select @id as id, @jmeno as jmeno, @prijmeni as p;
	delete from skola.znamka
		where id_student=@id;
	delete from skola.student 
		where id_student=@id and jmeno=@jmeno and @prijmeni=prijmeni;
go
begin tran ss
	exec smaz_studenta 1, 'Franta', 'Novák';
	select * from skola.student
	select * from skola.znamka
	select * from skola.student_zaloha
	select * from skola.znamky_zaloha
rollback tran ss;
go
-- 5.3
create proc vloz_vyucujiciho
@jmeno varchar(30),
@prijmeni varchar(30),
@predmet varchar(50)
as
	declare @i varchar(100)
	declare @new_uc int, @new_predm int

	set @i = (select top 1 u.jmeno from skola.ucitel as u join skola.vyucujici as v on v.id_ucitel=u.id_ucitel
			join skola.predmet as p on v.id_predmet=p.id_predmet
			where u.jmeno=@jmeno and u.prijmeni=@prijmeni and p.nazev=@predmet);
	if (@i is null)
		begin
			insert into skola.ucitel (jmeno, prijmeni) values(@jmeno, @prijmeni);
			set @new_uc = ident_current('skola.ucitel');
			insert into skola.predmet(nazev) values(@predmet);
			set @new_predm = ident_current('skola.predmet');
		end
	else
		begin
			print 'Chyba zaznam uz existuje';
		end
	if (@new_uc is not null and @new_predm is not null)
	begin
		insert into skola.vyucujici(id_ucitel, id_predmet) values(@new_uc, @new_predm);
	end
go
begin tran vv
	exec vloz_vyucujiciho 'Ferdo', 'Mravec', 'Fyzika';
	select * from skola.ucitel;
	select * from skola.vyucujici;
	select * from skola.predmet;
rollback tran vv
go
-- 5.4
create proc save_student
@jmeno varchar(20),
@prijmeni varchar(50),
@id_stud int output
as
	set @id_stud = (select top 1 id_student from skola.student where jmeno=@jmeno and prijmeni=@prijmeni);
	if(@id_stud is null)
		begin
			insert into skola.student(jmeno, prijmeni)
			values (@jmeno, @prijmeni);
			set @id_stud = @@identity;
		end
go
begin tran svs
	declare @noveID as int;
	exec save_student 'Rudolf', 'Horvath', @id_stud = @noveID output;
	select @noveID;
rollback tran svs
go
-- 5.5
create proc save_ucitel
@jmeno varchar(20),
@prijmeni varchar(50),
@id_ucitel int output,
@existuje bit output
as
	set @id_ucitel = (select top 1 id_ucitel from skola.ucitel where jmeno=@jmeno and prijmeni=@prijmeni);
	if(@id_ucitel is null)
		begin
			insert into skola.ucitel(jmeno, prijmeni)
			values (@jmeno, @prijmeni);
			set @id_ucitel = @@identity;
			set @existuje = 0;
		end
	else
		begin
			set @existuje = 0;
		end
go
begin tran svu
	declare @nove as int;
	declare @exists as bit;
	exec save_ucitel 'Anotonin', 'Dvorak', @id_ucitel=@nove output, @existuje=@exists output;
	select @nove, @exists;
rollback tran svu
go
-- 5.6
create proc vypis
@exists as bit,
@id as int
as
	if @exists = 1 
	begin
		print 'Ucitel uz existuje a jeho id je: ' + convert(varchar, @id);
	end;
	else
	begin
		print 'Bol vytvoreny novy ucitel a jeho id je: ' + convert(varchar, @id);
	end;
go
create proc save_ucitel1
@jmeno varchar(20),
@prijmeni varchar(50),
@id_ucitel int output,
@existuje bit output
as
	set @id_ucitel = (select top 1 id_ucitel from skola.ucitel where jmeno=@jmeno and prijmeni=@prijmeni);
	if(@id_ucitel is null)
		begin
			insert into skola.ucitel(jmeno, prijmeni)
			values (@jmeno, @prijmeni);
			set @id_ucitel = @@identity;
			set @existuje = 0;
		end
	else
		begin
			set @existuje = 0;
		end
		exec vypis @existuje, @id_ucitel;
go
begin tran svu
	declare @nove as int;
	declare @exists as bit;
	exec save_ucitel1 'Anotonin', 'Dvorak', @id_ucitel=@nove output, @existuje=@exists output;
rollback tran svu
go
-- 5.7.
create proc trans_hodn
@check as int
as
	if @check >= 90 and @check <= 100
		begin
			print 'A';
		end;
		else if @check >= 80 and @check <= 89
		begin
			print 'B';
		end;
		else if @check >= 70 and @check <= 79
		begin
			print 'C';
		end;
		else if @check >= 60 and @check <= 69
		begin
			print 'D';
		end;
		else if @check >=50 and @check <= 59
		begin
			print 'E';
		end;
		else
		begin
			print 'F';
		end;
go
create proc save_hodnoceni
@uc_jmeno as varchar(20),
@uc_prij as varchar(30),
@st_jmeno as varchar(20),
@st_prij as varchar(30),
@predmet as varchar(30),
@body as int
as
	--locals
	declare @id_uc as int;
	declare @exists as bit;
	exec vloz_vyucujiciho @uc_jmeno, @uc_prij, @predmet;
	exec save_ucitel @uc_jmeno, @uc_prij, @id_ucitel=@id_uc output, @existuje=@exists output;

	declare @id_stu as int;
	exec save_student @st_jmeno, @st_prij, @id_stud = @id_stu output;

	declare @check as int;
	set @check = (select top 1 zn.body from skola.student as s join skola.znamka as zn
					on s.id_student=zn.id_student join skola.ucitel as u on u.id_ucitel=zn.id_ucitel 
					join skola.predmet as p on p.id_predmet=zn.id_predmet
					where s.jmeno=@st_jmeno and s.prijmeni=@st_prij and 
							u.jmeno=@uc_jmeno and u.prijmeni=@uc_prij and
							p.nazev=@predmet); -- ci hodnotenie uz existuje
	if not @check is null
	begin
		exec trans_hodn @check;
	end;
	else
	begin
		insert into skola.znamka(id_student, id_ucitel, id_predmet, body) values
		(@id_stu, @id_uc, (select top 1 p.id_predmet from skola.predmet as p where p.nazev = @predmet ), @body);
		exec trans_hodn @body;
	end;
go
begin tran t
	exec save_hodnoceni 'Ferdo', 'Mravec', 'Jozef', 'Mak', 'Literatura', 64;
	select * from skola.student;
	select * from student;
rollback tran t
