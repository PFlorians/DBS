create database MI_Florians_Patrik_testik;
use MI_Florians_Patrik_testik;
go
create table student
(
	id_student int identity(1, 1),
	cislo_studenta int primary key not null,
	jmeno varchar (30),
	prijmeni varchar (50),
	adresa varchar (50),
	obec varchar (30),
	psc numeric (5),
	telefon numeric (9)
)

go
create table lektor
(
	id_lektora int identity(1, 1),
	cislo_lektora int primary key not null,
	jmeno varchar (30),
	prijmeni varchar (50),
	adresa varchar (50),
	obec varchar (30),
	psc numeric (5),
	telefon numeric (9)
)

go

create table kurs
(
	id_kursu int identity(1, 1),
	cislo_kursu varchar (4) primary key not null,
	nazev varchar (50),
	popis varchar (200)	
)
go
create table terminy
(
	id_terminu int identity(1, 1) primary key,
	rok varchar (9),
	semestr varchar (5),
	cislo_kursu varchar (4) foreign key references kurs (cislo_kursu),
	ucebna varchar (4),
	den varchar (5),
	cas varchar (5),
	cislo_lektora int foreign key references lektor (cislo_lektora)	
)
go
create table predpoklady
(
	id_predpokladu int identity(1, 1) primary key,
	cislo_kursu varchar (4) foreign key references kurs (cislo_kursu),
	cislo_predchozi varchar (4)
) 
go
create table hodnoceni
(
	id_hodnoceni int identity(1, 1) primary key,
	cislo_studenta int foreign key references student (cislo_studenta),
	id_terminu int foreign key references terminy (id_terminu),
	hodnoceni int
) 
go
create table aprobace
(
	id_aprobace int identity(1, 1) primary key,
	cislo_lektora int foreign key references lektor (cislo_lektora),	
	cislo_kursu varchar (4) foreign key references kurs (cislo_kursu)
) 

go
-- ukonceni tvorby tabulek


-- vlozeni studentu
insert into student (cislo_studenta, jmeno, prijmeni, adresa, obec, psc, telefon)
values (4567, 'Helena','Červená','Poříčí 128','Brno','60200','523698741')
insert into student (cislo_studenta, jmeno, prijmeni, adresa, obec, psc, telefon)
values (4965, 'Barbora','Studená','U Pergamenky 26','Praha','12000','258963147')
insert into student (cislo_studenta, jmeno, prijmeni, adresa, obec, psc, telefon)
values (6874, 'Jan','Čermák','U dvora 569','Jihlava','58698','365214895')
insert into student (cislo_studenta, jmeno, prijmeni, adresa, obec, psc, telefon)
values (7096, 'Karel','Holub','U sokolovny 21','Brno','63500','512963478')
insert into student (cislo_studenta, jmeno, prijmeni, adresa, obec, psc, telefon)
values (8513, 'Jiří','Adamec','Grohova 65','Brno','60200','587452369')
insert into student (cislo_studenta, jmeno, prijmeni, adresa, obec, psc, telefon)
values (8713, 'Jiří','Kolouch','Grohova 65','Olomouc','50200','587452369')
go
-- vlozeni kursu
insert into kurs (cislo_kursu, nazev, popis)
values ('X100', 'Základy PC','Úvodní kurz informatiky')
insert into kurs (cislo_kursu, nazev, popis)
values ('X201', 'Algoritmizace','Základy programování')
insert into kurs (cislo_kursu, nazev, popis)
values ('X202', 'Visual Basic','Programovací tecjniky ve VB')
insert into kurs (cislo_kursu, nazev, popis)
values ('X301', 'Základy zpracování dat','Struktura dat, techniky ukládání, práce s datovámi soubory')
insert into kurs (cislo_kursu, nazev, popis)
values ('X302', 'Datové modelování','Relační datový model, normalizace, E-R diagramy')
insert into kurs (cislo_kursu, nazev, popis)
values ('X401', 'Databázové systémy','Základy databází, SQL jazyk')
go


-- vlozeni lektoru
insert into lektor (cislo_lektora, jmeno, prijmeni, adresa, obec, psc, telefon)
values (25897, 'Václav','Horník','Hlavní třída 1','Jihlava','58601','214563987')
insert into lektor (cislo_lektora, jmeno, prijmeni, adresa, obec, psc, telefon)
values (36521, 'Martin','Dvořák','Křenová 54','Brno','62100','569743215')
insert into lektor (cislo_lektora, jmeno, prijmeni, adresa, obec, psc, telefon)
values (87421, 'Ladislav','Pálka','Otakara Ševčíka 63','Brno','60200','539715698')
insert into lektor (cislo_lektora, jmeno, prijmeni, adresa, obec, psc, telefon)
values (95471, 'Otakar','Možný','Kolejní 5','Brno','61600','411369852')
insert into lektor (cislo_lektora, jmeno, prijmeni, adresa, obec, psc, telefon)
values (95472, 'Ota','Pavel','Kolejní 5','Praha','61600','411369852')
go
-- vlozeni predpokladu
insert into predpoklady (cislo_kursu, cislo_predchozi)
values ('X201','X100')
insert into predpoklady (cislo_kursu, cislo_predchozi)
values ('X202','X201')
insert into predpoklady (cislo_kursu, cislo_predchozi)
values ('X302','X301')
insert into predpoklady (cislo_kursu, cislo_predchozi)
values ('X401','X302')
go

-- vlozeni aprobace
insert into aprobace (cislo_lektora, cislo_kursu)
values (25897,'X100')
insert into aprobace (cislo_lektora, cislo_kursu)
values (36521,'X201')
insert into aprobace (cislo_lektora, cislo_kursu)
values (36521,'X202')
insert into aprobace (cislo_lektora, cislo_kursu)
values (95471,'X202')
insert into aprobace (cislo_lektora, cislo_kursu)
values (95471,'X401')
insert into aprobace (cislo_lektora, cislo_kursu)
values (87421,'X301')
insert into aprobace (cislo_lektora, cislo_kursu)
values (87421,'X302')
insert into aprobace (cislo_lektora, cislo_kursu)
values (87421,'X401')
go

-- vlozeni terminu

insert into terminy (rok, semestr, cislo_kursu, ucebna, den, cas, cislo_lektora)
values ('2006/2007', 'Letní','X100','P384','Po','7-10',25897)
insert into terminy (rok, semestr, cislo_kursu, ucebna, den, cas, cislo_lektora)
values ('2006/2007', 'Letní','X201','P164','St','13-15',36521)
insert into terminy (rok, semestr, cislo_kursu, ucebna, den, cas, cislo_lektora)
values ('2006/2007', 'Letní','X401','P381','Po,Pá','9-11',87421)
insert into terminy (rok, semestr, cislo_kursu, ucebna, den, cas, cislo_lektora)
values ('2007/2008', 'Zimní','X202','P165','St','10-12',95471)
insert into terminy (rok, semestr, cislo_kursu, ucebna, den, cas, cislo_lektora)
values ('2007/2008', 'Zimní','X301','P292','St','17-19',87421)
insert into terminy (rok, semestr, cislo_kursu, ucebna, den, cas, cislo_lektora)
values ('2007/2008', 'Zimní','X302','P264','Čt','15-17',87421)
go
-- vlozeni hodnoceni
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('4567',1,2)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('4567',4,2)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('4965',3,1)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('6874',2,1)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('6874',6,1)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('7096',3,2)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('7096',5,3)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('7096',6,2)
insert into hodnoceni (cislo_studenta, id_terminu, hodnoceni)
values ('8513',3,3)
go
--- Dotaz 1
select jmeno +' ' + prijmeni as [Jméno a přijmení lektora]
from lektor
order by prijmeni DESC, jmeno ASC;
go
--- Dotaz 2
create view urc
as
select Určení= 
		case
		 when obec like '%Brno%' then 'Z Brna'
		 else 'Mimo Brno'
		 end
		 from lektor;
go
select Určení, count(Určení) as [Počet lektorů] from urc group by Určení;
--- Dotaz 3
go
select l.jmeno, l.prijmeni, k.nazev, t.rok from lektor as l full join terminy as t on l.cislo_lektora=t.cislo_lektora
		full join kurs as k on k.cislo_kursu=t.cislo_kursu;
go
--- Dotaz 4
select l.jmeno, l.prijmeni, avg(h.hodnoceni) as [Průměrné hodnocení], k.nazev
	from lektor as l join terminy as t on l.cislo_lektora=t.cislo_lektora
	join hodnoceni as h on t.id_terminu=h.id_terminu 
	join kurs as k on t.cislo_kursu=k.cislo_kursu
	group by l.jmeno, l.prijmeni, k.nazev
	order by l.prijmeni asc, l.jmeno asc;
-- Dotaz 5
go
select k.nazev as [Kursy bez předpokladů] from kurs as k left join predpoklady as p
		on p.cislo_kursu=k.cislo_kursu
		where p.id_predpokladu is null;


