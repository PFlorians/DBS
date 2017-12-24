--create database MI_Florians_Patrik_Cvicna;
--go
use MI_Florians_Patrik_Cvicna;
go
create schema skola authorization dbo;
go
create table skola.student(
	id_student int identity(1,1),
	jmeno varchar(20),
	prijmeni varchar(30)
)
go
create table skola.ucitel(
	id_ucitel int identity(1, 1),
	jmeno varchar(20),
	prijmeni varchar(30)
	)
go
create table skola.predmet(
	id_predmet int identity(1, 1),
	nazev varchar(50) not null
	)
go 
-- setting first primaries here
alter table skola.student add constraint PK_studentPrimary primary key(id_student);
alter table skola.ucitel add constraint PK_ucitelPrimary primary key(id_ucitel);
alter table skola.predmet add constraint PK_predmetPrimary primary key(id_predmet);
go
create table skola.znamka(
	--foreign keys go here
	id_student int not null,
	id_predmet int not null,
	id_ucitel int not null,
	body int not null
	)
go
create table skola.vyucujici(
	id_ucitel int not null,
	id_predmet int not null
)
go
alter table skola.znamka add constraint FK_znamkaForStud foreign key(id_student) references skola.student(id_student);
alter table skola.znamka add constraint FK_znamkaForPredm foreign key(id_predmet) references skola.predmet(id_predmet);
alter table skola.znamka add constraint FK_znamkaForUcitel foreign key(id_ucitel) references skola.ucitel(id_ucitel);
go
--druhy blok prikazov alter
alter table skola.vyucujici add constraint FK_vyucForUcitel foreign key(id_ucitel) references skola.ucitel(id_ucitel);
alter table skola.vyucujici add constraint FK_vyucForPredm foreign key(id_predmet) references skola.predmet(id_predmet);

-- end creations begin secondary alterations 
alter table skola.vyucujici add constraint PK_vyucujiciZlozPrimary primary key(id_ucitel, id_predmet);
alter table skola.znamka add constraint PK_znamkaZlozPrimary primary key(id_student, id_predmet);
-- end secondary alterations
go

--inserts go here
insert into skola.student(jmeno, prijmeni)
values('Franta', 'Novák'), ('Pepa', 'Janů'), ('Jarda', 'Pořízek'), 
		('Ferda', 'Petržela'), ('Roman', 'Kolář');
go
insert into skola.ucitel(jmeno, prijmeni)
	values('Vlastimil', 'Dvořák'), ('Jaromír', 'Novotný'), ('Tomáš', 'Marný');
go
insert into skola.predmet(nazev)
	values('matematika'), ('chemie'), ('dějepis'), ('čeština');

-- end of basic inserts here
-- binded inserts go here data required beyond this point
insert into skola.vyucujici(id_predmet, id_ucitel)
	values (3,1), (3, 2), (1, 2);
insert into skola.znamka(id_student, id_predmet, id_ucitel, body)
	values (1, 1, 3, 65), (2, 1, 3, 45), (3, 1, 3, 100), (4, 1, 3, 50), 
			(1, 2, 3, 20), (2, 2, 3, 50), (3, 2, 3, 80), (4, 2, 3, 60);

--end binded inserts here 
-- check out data after this line
select * from skola.znamka;
select * from skola.vyucujici;
select * from skola.predmet;
select * from skola.student;
select * from skola.ucitel;
