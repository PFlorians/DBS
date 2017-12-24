
create database projektova;
--purge sequence
--use master
--go
--drop database projektova
---------------------------
--reset sequence
-- dbcc checkident (<table>, reseed, 0)
go
use projektova;
go
CREATE TABLE pab (
    id_pab int identity(1, 1) NOT NULL,
	jmeno varchar(20) not null,
	prijmeni varchar(30) not null,
    CONSTRAINT pab_pk PRIMARY KEY  (id_pab)
);	
go
CREATE TABLE platby (
    id int identity(1, 1) NOT NULL,
	ucel varchar(50) not null,
	vyska_platby money not null default 0,
	datum_prijeti datetime not null default getdate(),
	potvrzeno bit not null default 0,
    student_id_st int  NOT NULL,
    CONSTRAINT platby_pk PRIMARY KEY  (id)
);
go
CREATE TABLE fakulta (
    id_fak int identity(1, 1) NOT NULL,
	nazev varchar(100) not null,
    CONSTRAINT fakulta_pk PRIMARY KEY  (id_fak)
);
go
CREATE TABLE hodnotenie_ucitelov (
    id int identity(1, 1) NOT NULL,
    termin_hodnoceni_ZP_id_hodp int  NOT NULL,
    vyucujici_id_uc int  NOT NULL,
	stupnice_id int not null,
    CONSTRAINT hodnotenie_ucitelov_pk PRIMARY KEY  (id)
);
go
CREATE TABLE prace_v_termine (
    id int identity(1, 1) NOT NULL,
    zaverecna_prace_id_prac int  NOT NULL,
    termin_hodnoceni_ZP_id_hodp int  NOT NULL,
    CONSTRAINT prace_v_termine_pk PRIMARY KEY  (id)
);
go
CREATE TABLE predmet (
    zkratka varchar(20)  NOT NULL,
	nazev varchar(100) not null,
    st_obor_id_so int  NOT NULL,
    vyucujici_id_uc int  NOT NULL,
    CONSTRAINT predmet_pk PRIMARY KEY  (zkratka)
);

go
CREATE TABLE predmet_student (
    id int identity(1, 1) NOT NULL,
    student_id_st int  NOT NULL,
    predmet_zkratka varchar(20)  NOT NULL,
    CONSTRAINT predmet_student_pk PRIMARY KEY  (id)
);
go
CREATE TABLE prihlaska (
    id_pr int identity(1, 1) NOT NULL,
	datum_podania date not null,
	poplatok_zaplateny bit not null default 0,
    student_id_st int  NOT NULL,
    st_obor_id_so int  NOT NULL,
    CONSTRAINT prihlaska_pk PRIMARY KEY  (id_pr)
);
go
create table vysledky_prijmani(
	id int identity(1, 1) not null,
	hodnoceni int,
	prihlaska_id_pr int not null,
	prijmaci_riz_id_riz int not null,
	constraint vysledky_prijmani_pk primary key(id)
);

go
CREATE TABLE prijmaci_riz (
    id_riz int identity(1, 1) NOT NULL,
	datum_konani date not null,
	popis_mista_konani varchar(40) not null,
	doba_trvani time,
	cas_konania time,
    CONSTRAINT prijmaci_riz_pk PRIMARY KEY (id_riz)
);
go
CREATE TABLE referentka (
    id_ref int identity(1, 1) NOT NULL,
	jmeno varchar(20) not null,
	prijmeni varchar(30) not null,
	fakulta_id_fak int not null,
    CONSTRAINT referentka_pk PRIMARY KEY  (id_ref)
);
go
CREATE TABLE referentka_prijZ (
    id int identity(1, 1) NOT NULL,
    prijmaci_riz_ID_riz int  NOT NULL,
    referentka_ID_ref int  NOT NULL,
    CONSTRAINT referntkz_prijZ_pk PRIMARY KEY  (id)
);
go
CREATE TABLE rocnikovy_ucitel (
    id_ru int identity(1, 1) NOT NULL,
	jmeno varchar(20) not null,
	prijmeni varchar(30) not null,
    CONSTRAINT rocnikovy_ucitel_pk PRIMARY KEY  (id_ru)
);
go
CREATE TABLE st_obor (
    id_so int identity(1, 1) NOT NULL,
	nazev varchar(100) not null unique,
	c_oboru varchar(20) not null unique,
	dlzka_ob int not null,
    st_program_id_sp int  NOT NULL,
    CONSTRAINT st_obor_pk PRIMARY KEY  (id_so)
);
go
CREATE TABLE st_program (
    id_sp int identity(1, 1) NOT NULL,
	nazev varchar(100) not null unique,
	profil_absolventa varchar(1024) not null,
	c_programu varchar(15) not null unique,
    ustav_nazev varchar(255)  NOT NULL,
    CONSTRAINT st_program_pk PRIMARY KEY  (id_sp)
);
go
CREATE TABLE stud_zap (
    id int identity(1, 1) NOT NULL,
	pokus int not null, --check
    student_ID_st int  NOT NULL,
    zapocet_ID_zap int  NOT NULL,
    CONSTRAINT stud_zap_pk PRIMARY KEY  (id)
);
go
CREATE TABLE stud_zk (
    id int identity(1, 1) NOT NULL,
	pokus int not null,
    student_ID_st int  NOT NULL,
    zkouska_ID_zk int  NOT NULL,
    CONSTRAINT stud_zk_pk PRIMARY KEY  (id)
);
go
CREATE TABLE student (
    id_st int identity(1, 1) NOT NULL,
	login varchar(20) not null unique,
	jmeno varchar(20) not null,
	prijmeni varchar(30) not null,
	rodne_cislo numeric(11) not null,
	vek int not null,
	pohlavi bit,
	rocnik int,
	dat_zac_stud date,
	dat_ukonceni_stud date,
	vzdelani_id int not null,
    CONSTRAINT student_pk PRIMARY KEY  (id_st)
);
go
CREATE TABLE termin_hodnoceni_ZP (
    id_hodp int identity(1, 1) NOT NULL,
	datum_konani date not null,
    CONSTRAINT termin_hodnoceni_ZP_pk PRIMARY KEY  (id_hodp)
);
go
CREATE TABLE ucene_predmety (
    id int identity(1, 1) NOT NULL,
    rocnikovy_ucitel_id_ru int  NOT NULL,
    predmet_zkratka varchar(20)  NOT NULL,
    CONSTRAINT ucene_predmety_pk PRIMARY KEY  (id)
);
go
CREATE TABLE ustav (
    nazev varchar(255)  NOT NULL,
    fakulta_id_fak int  NOT NULL,
    CONSTRAINT ustav_pk PRIMARY KEY  (nazev)
);
go
CREATE TABLE vyucujici (
    id_uc int identity(1, 1) NOT NULL,
	jmeno varchar(20),
	prijmeni varchar(30),
	druh_vyuc_id int not null,
    CONSTRAINT vyucujici_pk PRIMARY KEY  (id_uc)
);
go
CREATE TABLE zapocet (
    id_zap int identity(1, 1) NOT NULL,
	datum_konani date not null,
	misto_popis varchar(255) not null,
    vyucujici_id_uc int  NOT NULL,
    CONSTRAINT zapocet_pk PRIMARY KEY  (id_zap)
);
go
create table hodnotenie_zap(
	id int identity(1, 1) not null,
	vyucujici_id_uc int not null,
	zapocet_id_zap int not null,
	student_id_st int not null,
	stupnice_id int not null,
	rocnikovy bit,
	constraint hodnotenie_zap_pk primary key(id)
);
go
CREATE TABLE zaverecna_prace (
    id_prac int identity(1, 1) NOT NULL,
	zadani varchar(100) unique not null,
	datum_zverejneni date not null,
    vyucujici_id_uc int  NOT NULL,
    student_id_st int  NOT NULL,
	tema_id int not null,
    CONSTRAINT zaverecna_prace_pk PRIMARY KEY  (id_prac)
);
go
CREATE TABLE zkouska (
    id_zk int identity(1, 1) NOT NULL,
	datum_konani date not null,
	misto_popis varchar(255) not null,
    vyucujici_id_uc int  NOT NULL,
    CONSTRAINT zkouska_pk PRIMARY KEY  (id_zk)
);
go
create table hodn_zk(
	id int identity(1, 1) not null,
	vyucujici_id_uc int not null,
	student_id_st int not null,
	stupnice_id int not null,
	zkouska_id_zk int not null,
	rocnikovy bit,
	constraint pk_hodn_zk primary key(id)
);
go
create table vzdelani(
	id int identity(1,1) not null, 
	popis varchar(50),
	constraint vzdelani_pk primary key (id)
);
go
create table stupnice(
	id int identity(1, 1) not null,
	znamka char(1) not null unique,
	body_min int not null unique,
	popis varchar(20) not null unique,
	constraint stupnice_pk primary key (id)
);
go
create table pravo_zapoc(
	id int identity(1, 1) not null,
	vyucujici_id_uc int not null,
	zapocet_id_zap int not null,
	rocnikovy_ucitel_id_ru int not null,
	constraint pravo_zapoc_pk primary key (id)
);
go
create table pravo_zk(
	id int identity(1, 1) not null,
	zkouska_id_zk int,
	vyucujici_id_uc int,
	rocnikovy_ucitel_id_ru int,
	constraint pravo_zk_pk primary key (id)
);
go
create table predmety_na_zapoctoch(
	id int identity(1, 1) not null,
	zapocet_id_zap int not null, 
	predmet_zkratka varchar(20) not null,
	constraint predmety_na_zapoctoch_pk primary key (id)
);
go
create table predmety_na_skuskach(
	id int identity(1, 1) not null,
	zkouska_id_zk int not null, 
	predmet_zkratka varchar(20) not null,
	constraint predmety_na_skuskach_pk primary key (id)
);
go
create table dozorcovia_programov(
	id int identity(1, 1) not null,
	st_program_id_sp int not null,
	pab_id_pab int not null,
	constraint dozorcovia_programov_pk primary key (id)
);
go
create table karta_predmetu(
	lang varchar(2) not null,
	rocnik int not null,
	semestr varchar(2) not null,
	kredity int not null,
	ukonceni varchar(5) not null,
	jazyk varchar(2) not null,
	popis varchar(2048),
	povinnost_id int not null,
	predmet_zkratka varchar(20) not null,
	constraint karta_predmetu_pk primary key (lang, predmet_zkratka)
);
go
create table povinnost(
	id int identity(1, 1) not null,
	povinnost varchar(10),
	constraint povinnost_pk primary key (id)
);
go
create table druh_vyuc(
	id int identity(1, 1) not null,
	typ varchar(10)
	constraint druh_vyuc_pk primary key(id)
);
go
create table adresa(
	id int identity(1, 1) not null,
	krajina varchar(100) not null,
	mesto varchar(50) not null,
	ulica varchar(50) not  null,
	psc varchar(7) not null,
	student_id_st int not null,
	constraint adresa_pk primary key(id)
);
go
create table vyucujici_v_programe(
	id int identity(1, 1) not null,
	st_program_id_sp int not null,
	vyucujici_id_uc int not null,
	constraint pk_vyucujici_v_programe primary key(id)
);
go
create table tema(
	id int identity(1, 1) not null,
	tema varchar(255) not null unique,
	vyucujici_id_uc int not null,
	constraint pk_tema primary key(id)
);
go

-- foreign keys
--hodn_zk
go
alter table hodn_zk
add constraint fk_vyuc_hzk foreign key (vyucujici_id_uc) references vyucujici(id_uc);
alter table hodn_zk
add constraint fk_stud_hzk foreign key (student_id_st) references student(id_st);
alter table hodn_zk
add constraint fk_stup_hzk foreign key (stupnice_id) references stupnice(id);
alter table hodn_zk
add constraint fk_zkous_hzk foreign key (zkouska_id_zk) references zkouska(id_zk);
-- hodn_zap
alter table hodnotenie_zap
add constraint fk_uc_hzp foreign key(vyucujici_id_uc) references vyucujici(id_uc);
alter table hodnotenie_zap 
add constraint fk_zap_hzp foreign key(zapocet_id_zap) references zapocet(id_zap);
alter table hodnotenie_zap
add constraint fk_stud_zap foreign key(student_id_st) references student(id_st);
alter table hodnotenie_zap
add constraint fk_stup_zap foreign key(stupnice_id) references stupnice(id);
--tema
alter table tema
add constraint fk_vyuc_tema foreign key (vyucujici_id_uc) references vyucujici(id_uc);
--platby
alter table platby 
add constraint fk_student_id foreign key (student_ID_st) references student(ID_st);
go
--student
alter table student
add constraint fk_stud_vz foreign key (vzdelani_id) references vzdelani(id);
go
--zp
alter table zaverecna_prace
add constraint fk_zp_stud foreign key (student_id_st) references student(id_st);
alter table zaverecna_prace
add constraint fk_zp_vyuc foreign key (vyucujici_id_uc) references vyucujici(id_uc);
alter table zaverecna_prace
add constraint fk_zp_tema foreign key (tema_id) references tema(id);
go
--prace v termine
alter table prace_v_termine
add constraint fk_zp_pvt foreign key (zaverecna_prace_id_prac) references zaverecna_prace(id_prac);
alter table prace_v_termine
add constraint fk_termh_pvt foreign key (termin_hodnoceni_zp_id_hodp) references termin_hodnoceni_ZP(id_hodp);
go
--hodnoteni_ucitelov
alter table hodnotenie_ucitelov
add constraint fk_stupn_huc foreign key (stupnice_id) references stupnice(id);
alter table hodnotenie_ucitelov
add constraint fk_vyucujici_huc foreign key (vyucujici_id_uc) references vyucujici(id_uc);
alter table hodnotenie_ucitelov
add constraint fk_termhod_huc foreign key (termin_hodnoceni_zp_id_hodp) references termin_hodnoceni_zp(id_hodp);
go
--stud_zk
alter table stud_zk
add constraint fk_stud_studzk foreign key (student_id_st) references student(id_st);
alter table stud_zk
add constraint fk_zkous_studzk foreign key (zkouska_id_zk) references zkouska(id_zk);
go
--zkouska
alter table zkouska
add constraint fk_vyuc_zk foreign key (vyucujici_id_uc) references vyucujici(id_uc);
go
--vyucujici
alter table vyucujici
add constraint fk_druhv_vyuc foreign key (druh_vyuc_id) references druh_vyuc(id);
go
--predm na skusk
alter table predmety_na_skuskach 
add constraint fk_zk_pns foreign key (zkouska_id_zk) references zkouska(id_zk);
alter table predmety_na_skuskach 
add constraint fk_predm_pns foreign key (predmet_zkratka) references predmet(zkratka);
go
--pravo zk
alter table pravo_zk
add constraint fk_zk_pzk foreign key (zkouska_id_zk) references zkouska(id_zk);
alter table pravo_zk
add constraint fk_vyuc_pzk foreign key (vyucujici_id_uc) references vyucujici(id_uc);
alter table pravo_zk
add constraint fk_rocu_pzk foreign key (rocnikovy_ucitel_id_ru) references rocnikovy_ucitel(id_ru);
go
--stud zap
alter table stud_zap
add constraint fk_stud_studzap foreign key (student_id_st) references student(id_st);
alter table stud_zap
add constraint fk_zap_studzap foreign key (zapocet_id_zap) references zapocet(id_zap);
go
--zapocet
alter table zapocet
add constraint fk_vyuc_zap foreign key (vyucujici_id_uc) references vyucujici(id_uc);
go
--pravo zapoc
alter table pravo_zapoc
add constraint fk_vyuc_pravzap foreign key (vyucujici_id_uc) references vyucujici(id_uc);
alter table pravo_zapoc
add constraint fk_zapoc_pravzap foreign key (zapocet_id_zap) references zapocet(id_zap);
alter table pravo_zapoc
add constraint fk_rocuc_pravzap foreign key (rocnikovy_ucitel_id_ru) references rocnikovy_ucitel(id_ru);
go
--predmety na zapoc
alter table predmety_na_zapoctoch
add constraint fk_zap_pnz foreign key (zapocet_id_zap) references zapocet(id_zap);
alter table predmety_na_zapoctoch
add constraint fk_predm_pnz foreign key (predmet_zkratka) references predmet(zkratka);
go
--ucene predm
alter table ucene_predmety
add constraint fk_rocuc_ucpr foreign key (rocnikovy_ucitel_id_ru) references rocnikovy_ucitel(id_ru);
alter table ucene_predmety
add constraint fk_predm_ucpr foreign key (predmet_zkratka) references predmet(zkratka);
go
--predmet student
alter table predmet_student
add constraint fk_stud_predstud foreign key (student_id_st) references student(id_st);
alter table predmet_student
add constraint fk_predm_predstud foreign key (predmet_zkratka) references predmet(zkratka);
go
--predmet
alter table predmet
add constraint fk_vyuc_predm foreign key (vyucujici_id_uc) references vyucujici(id_uc);
alter table predmet
add constraint fk_obor_predm foreign key (st_obor_id_so) references st_obor(id_so);
go
--karta predmetu
alter table karta_predmetu 
add constraint fk_povin_kartpredm foreign key (povinnost_id) references povinnost(id);
alter table karta_predmetu 
add constraint fk_predm_kartpredm foreign key (predmet_zkratka) references predmet(zkratka);
go
--prihlaska
alter table prihlaska
add constraint fk_stud_prihl foreign key (student_id_st) references student(id_st);
alter table prihlaska
add constraint fk_so_prihl foreign key (st_obor_id_so) references st_obor(id_so);
go
--st obor
alter table st_obor
add constraint fk_stpo_so foreign key (st_program_id_sp) references st_program(id_sp);
go
--st_program
alter table st_program
add constraint fk_ustav_stpo foreign key (ustav_nazev) references ustav(nazev);
go
--ustav
alter table ustav
add constraint fk_fak_ustav foreign key (fakulta_id_fak) references fakulta(id_fak);
go
--referentka prijz
alter table referentka_prijZ 
add constraint fk_prijriz_refprijz foreign key (prijmaci_riz_id_riz) references prijmaci_riz(id_riz);
alter table referentka_prijZ 
add constraint fk_refer_refprijz foreign key (referentka_id_ref) references referentka(id_ref);
go
--dozorcovia progr
alter table dozorcovia_programov
add constraint fk_stpo_dozor foreign key (st_program_id_sp) references st_program(id_sp);
alter table dozorcovia_programov
add constraint fk_pab_dozor foreign key (pab_id_pab) references pab(id_pab);
go
--adresa
alter table adresa
add constraint fk_stud_addr foreign key (student_id_st) references student(id_st);
go
-- vysl_prijmani
alter table vysledky_prijmani
add constraint fk_prihl_vyslp foreign key (prihlaska_id_pr) references prihlaska(id_pr);
alter table vysledky_prijmani
add constraint fk_prijz_vyslp foreign key (prijmaci_riz_id_riz) references prijmaci_riz(id_riz);
go
-- referentka
alter table referentka 
add constraint fk_fak_ref foreign key (fakulta_id_fak) references fakulta(id_fak);
go
-- vyucujici_v_programe
alter table vyucujici_v_programe
add constraint fk_vyuc_vvp foreign key (vyucujici_id_uc) references vyucujici(id_uc);
alter table vyucujici_v_programe
add constraint sk_stprog_vvp foreign key (st_program_id_sp) references st_program(id_sp);
go
go
-- other constraints//check, unique, sparse, default, 
--student vek >= 18
alter table student
add constraint chk_age_student check (vek >= 18);
-- stud_zk pokus <= 2
alter table stud_zk
add constraint chk_pokus check (pokus <= 2);
--stud zap
alter table stud_zap
add constraint chk_pokus_zap check (pokus <= 2);
--stud vzdelanie >=3
alter table student
add constraint chk_vzdelanie check(vzdelani_id >= 3);
-- prihlaska default podatnie
alter table prihlaska
add constraint def_datum default getdate() for datum_podania;
-- platby
alter table platby
add constraint chk_vyska check(vyska_platby >= 0);
go
-- inserts
	-- ciselniky
	-- vzdelanie:	1 - stredoskolske s maturitou
				--	2 - stredoskolske s maturitou a vyucnym listom
				--	3 - vysokoskolske 1. stupen (Bc.)
				--  4 - Vysokolske 2 stupen (Ing./Mgr.)
				--  5 - vysokoskolske 3 stupen
insert into vzdelani(popis)
	values ('stredoškolské s maturitou'), ('stredoškolské s maturitou a výučným listom'),
			('vysokoškolské 1. stupňa'), ('vysokoškolské 2. stupňa'), ('vysokoškolské 3. stupňa');
	--  stupnica moze byt osetrene programovo alebo prihodime body
insert into stupnice(znamka, body_min, popis)
	values ('A', 90, 'výborně'), ('B', 80, 'velmi dobře'), 
			('C', 70, 'dobře'), ('D', 60, 'uspokojivě'), ('E', 50, 'dostatečně'), ('F', 0, 'nevyhovující');
	-- druh_vyucujiciho
insert into druh_vyuc(typ) values ('učitel'), ('garant');
	-- fakulty nezahrna USI, CEITEC a CESA
insert into fakulta(nazev)
	values ('Fakulta architektury'), ('Fakulta elektrotechniky a komunikačních technologií'),
			('Fakulta chemická'), ('Fakulta informačních technologií'), ('Fakulta podnikatelská'),
			('Fakulta stavební'), ('Fakulta strojního inženýrství'), ('Fakulta výtvarných umění');
	-- ustavy
		-- FA
insert into ustav(fakulta_id_fak, nazev)
	values (1, 'Ústav teorie architektury'), (1, 'Ústav urbanismu'), (1, 'Ústav stavitelství'), (1, 'Ústav zobrazování'),
			(1, 'Ústav navrhování'), (1, 'Ústav památkové péče'), (1, 'Ústav prostorové tvorby'), (1, 'Ústav experimentální tvorby'),
			(1, 'Knihovna FA'), (1, 'Výpočetní centrum'), (1, 'Modelové centrum');
		-- FEKT
insert into ustav(fakulta_id_fak, nazev)
	values (2, 'Ústav automatizace a měřicí techniky'), (2, 'Ústav biomedicínského inženýrství'),
			(2, 'Ústav elektroenergetiky'), (2, 'Ústav elektrotechnologie'), (2, 'Ústav fyziky'), (2, 'Ústav jazyků'),
			(2, 'Ústav matematiky'), (2, 'Ústav mikroelektroniky'), (2, 'Ústav radioelektroniky'), (2, 'Ústav teoretické a experimentální elektrotechniky'),
			(2, 'Ústav telekomunikací'), (2, 'Ústav výkonové elektrotechniky a elektroniky'), (2, 'Centrum výzkumu a využití obnovitelných zdrojů energie'),
			(2, 'Centrum senzorických, informačních a komunikačních systémů');
		-- FCH
insert into ustav(fakulta_id_fak, nazev) 
		values (3, 'Ústav fyzikální a spotřební chemie'), (3, 'Ústav chemie materiálů'), (3, 'Ústav chemie a technologie ochrany životního prostředí'),
				(3, 'Ústav chemie potravin a biotechnologií'), (3, 'Centrum materiálového výzkumu');
		-- FIT
insert into ustav(fakulta_id_fak, nazev)
		values (4, 'Ústav počítačových systémů'), (4, 'Ústav informačních systémů'), (4, 'Ústav inteligentních systémů'),
		(4, 'Ústav počítačové grafiky a multimédií'), (4, 'Výzkumné centrum informačních technologií'), (4, 'Centrum výpočetní techniky');
		-- FP
insert into ustav(fakulta_id_fak, nazev)
		values (5, 'Ústav ekonomiky'), (5, 'Ústav financí'), (5, 'Ústav informatiky'), (5, 'Ústav managementu');
		-- FAST
insert into ustav(fakulta_id_fak, nazev)
		values (6, 'Ústav matematiky a deskriptivní geometrie'), (6, 'Ústav fyziky FAST'), (6, 'Ústav chemie'), (6, 'Ústav stavební mechaniky'),
		(6, 'Ústav geodézie'), (6, 'Ústav geotechniky'), (6, 'Ústav pozemního stavitelství'), (6, 'Ústav architektury'), 
		(6, 'Ústav technologie stavebních hmot a dílců'), (6, 'Ústav betonových a zděných konstrukcí'), (6, 'Ústav pozemních komunikací'),
		(6, 'Ústav železničních konstrukcí a staveb'), (6, 'Ústav kovových a dřevěných konstrukcí'), (6, 'Ústav vodního hospodářství obcí'),
		(6, 'Ústav vodních staveb'), (6, 'Ústav vodního hospodářství krajiny'), (6, 'Ústav technických zařízení budov'), 
		(6, 'Ústav automatizace inženýrských úloh a informatiky'), (6, 'Ústav stavební ekonomiky a řízení'), 
		(6, 'Ústav technologie, mechanizace a řízení staveb'), (6, 'Ústav stavebního zkušebnictví'), (6, 'Ústav společenských věd');
		-- FSI
insert into ustav(fakulta_id_fak, nazev)
		values (7, 'Ústav matematiky FSI'), (7, 'Ústav fyzikálního inženýrství'), 
		(7, 'Ústav mechaniky těles, mechatroniky a biomechaniky'), (7, 'Ústav materiálových věd a inženýrství'), (7, 'Ústav konstruování'), 
		(7, 'Energetický ústav'), (7, 'Ústav strojírenské technologie'),
		(7, 'Ústav výrobních strojů, systémů a robotiky'), (7, 'Ústav procesního inženýrství'), (7, 'Ústav automobilního a dopravního inženýrství'),
		(7, 'Letecký ústav'), (7, 'Ústav automatizace a informatiky'), (7, 'Ústav jazyků FSI'), (7, 'Laboratoř přenosu tepla a proudění'),
		(7, 'NETME Centre');
		-- FVU
insert into ustav(fakulta_id_fak, nazev)
		values(8, 'Ateliéry'), (8, 'Katedra teorií a dějin umění'), (8, 'Kabinet večerní kresby'), (8, 'Kabinet audiovizuálních technologií FAVU VUT'),
		(8, 'Kabinet informačních technologií'), (8, 'Knihovna');
	-- povinnost
insert into povinnost(povinnost) values ('P'), ('PV'), ('V'), ('S');
	--	referentka
insert into referentka(jmeno, prijmeni, fakulta_id_fak)
		values('Edita', 'Makova', 4), ('Jaroslava', 'Kielecka', 1), ('Slavomira', 'Velka', 2), ('Ivana', 'Tadeasova', 3),
			('Anna', 'Mala', 5), ('Eugenia', 'Zapotocka', 6), ('Miroslava', 'Obycajna', 7), ('Jozefina', 'Goldenbachova', 8);
	-- vyucujici
insert into vyucujici(jmeno, prijmeni, druh_vyuc_id)
		values ('Ing.Petr', 'Dydowicz,Ph.D.', 2), ('Doc.Ing.Stanislav', 'Škapa,Ph.D.', 2), ('Doc.PhDr.Iveta', 'Šimberová,Ph.D.', 2),
		('Ing.Lenka', 'Niebauerová', 2), ('Doc.Ing.František', 'Bartes,Csc.', 2), ('Mgr.Pavel', 'Sedláček', 2), ('Ing.Karel', 'Doubravský,Ph.D.', 2),
		('Prof.RNDr.Ivan', 'Mezník,Csc.', 2), ('Ing.Jiří', 'Kříž, Ph.D.', 2), ('Prof.Ing.Karel', 'Rais, Csc.,MBA', 2), 
		('Doc.Ing.Petr', 'Dostál, Csc.', 2), ('Mgr.Pavel', 'Sedláček', 2), ('Doc.Ing.Miloš', 'Koch, Csc.', 2), ('Ing.Viktor', 'Ondrák, Ph.D.', 2),
		('Doc.Ing.Mária', 'Režňáková, Csc.', 2), ('Ing.Helena', 'Hanušová, Csc.', 2), ('Ing.Jiří', 'Kříž, Ph.D.', 2), 
		('Ing.Robert', 'Zich, Ph.D.', 2), ('Doc.Ing.František', 'Bartes, Csc.', 2);
	-- st_program
insert into st_program(nazev, profil_absolventa, c_programu, ustav_nazev)
	values ('Msc. In Business and Informatics', 'Cílem studijního oboru je získání zkušeností a 
				dovedností v oblasti nasazování a využívání moderních informačních a komunikačních 
				technologií k podpoře vrcholového managementu. Na jedné straně jsou tu firmy plné specialistů ve svém oboru, 
				například ve strojírenství, a na straně druhé jsou společnosti zabývající se ICT.', 'ABC123', 'Ústav informatiky');
	-- st_obor
insert into st_obor(nazev, c_oboru, dlzka_ob, st_program_id_sp)
	values ('Msc. In Business and Informatics', 'CBA321', 2, 1);
	--predmet
	
insert into predmet(zkratka, vyucujici_id_uc, nazev, st_obor_id_so)--bud treba upravit pre prezentaciu nech sa to indexuje od 1
	values ('SapC',  1, 'Advanced Programming', 1), ('SubeC',  2, 'Understanding Business Environment', 1), 
	('SmC',  3, 'Marketing', 1), ('SpmC',  4, 'Project Management', 1), ('SqmC',  5, 'Quality Management', 1),
	('Sel1C',  6, 'English Language', 1), ('SsmC',  7, 'Statistics models', 1), ('SemC',  8, 'Econometrics models', 1),
	('SbiC',  9, 'Business Intelligence', 1), ('SorC',  10, 'Operational Research', 1), ('SsaC',  11, 'Simulation analysis', 1),
	('Sel2C',  12, 'English Language', 1), ('SisC',  13, 'Information Systems', 1), ('SictmC',  14, 'ICT Management', 1),
	('SfaC',  15, 'Financial analysis', 1), ('SmaC',  16, 'Managerial Accounting', 1), ('ScpC',  9, 'Consultancy Project', 1),
	('SrmC',  10, 'Risk Management', 1), ('SstmC',  18, 'Strategic Management', 1), ('SciC',  19, 'Competitive Intelligence', 1),
	('SdC',  9, 'Dissertation', 1);
	-- PAB
	
insert into pab(jmeno, prijmeni)
	values ('Jozef', 'Pereslenyi'), ('Imre', 'Rakoczi'), ('Pavol', 'Huska'), ('Andrej', 'Maliar');
	-- rocnikovy ucitel
insert into rocnikovy_ucitel(jmeno, prijmeni)
	values ('Alfred', 'Potocky'), ('David', 'Kysucky'), ('Roman', 'Mak');
go

go
-- views
--pohlad na osobne info
create view studentPersonalInfo -- len studentovi
as
	select s.jmeno as [jméno], s.prijmeni as [příjmení], s.login as [login], s.vek as [věk], s.rodne_cislo as [rodné číslo],
		pohlavie = case s.pohlavi
					when 0 then 'žena'
					else 'muž'
					end, [datum začátku studia] = case 
													when (s.dat_zac_stud is null) then 'neurčeno'
													else convert(varchar(100), s.dat_zac_stud, 101)
													end, [datum ukončení studia] = case
																					when s.dat_ukonceni_stud is null then 'neurčeno'
																					else convert(varchar(100), s.dat_ukonceni_stud, 101)
																					end,
					a.krajina as krajina, a.mesto as [město], a.ulica as ulice, a.psc as [PSČ], v.popis as [vzdělání]
	 from student as s join adresa as a on s.id_st = a.student_id_st
		join vzdelani as v on v.id=s.vzdelani_id;
go
create view zobrazTerminyPrijimaciekAReferentky -- pre studentov
as
	select pz.id_riz [ID], pz.datum_konani as [datum konání], pz.cas_konania as [čas konání], pz.doba_trvani as [doba trvání], 
			pz.popis_mista_konani as [popis místa konání], r.jmeno + ' ' + r.prijmeni + ' ' + f.nazev as [Referentka]
	 from prijmaci_riz as pz join referentka_prijZ as rpz on pz.id_riz=rpz.prijmaci_riz_id_riz
		join referentka as r on r.id_ref=rpz.referentka_ID_ref join fakulta as f on r.fakulta_id_fak=f.id_fak;
go
create view zobraz_info_o_prihlaskach -- pre referentku
as 
	select s.jmeno + ' ' + s.prijmeni as [student] , s.login as [login], p.id_pr [ID přihlášky] 
		from prihlaska as p join student as s on s.id_st=p.student_id_st;
go
create view zobraz_platby-- len studentovi a referentke
as
	select * from platby;
go
create view zobraz_limitovane_info_studenti -- pre referentku info o studentoch
as
	select  s.jmeno + ' ' + s.prijmeni as [student], s.login as [login]
	, stav=case	
				when p.potvrzeno = 0 then 'nezaplaceno'
				else 'zaplaceno'
			end, p.vyska_platby as [výše platby]
	  from platby as p 
		join student as s on p.student_id_st=s.id_st
			where ucel like 'prihlaska';
go
create view zobraz_moje_prijz --pre referentku
as 
	select r.jmeno + ' ' + r.prijmeni as [referentka], pz.datum_konani, pz.popis_mista_konani, pz.cas_konania, pz.doba_trvani 
		from referentka_prijZ as rfpz join referentka as r
		on r.id_ref=rfpz.referentka_ID_ref join prijmaci_riz as pz on
		pz.id_riz=rfpz.prijmaci_riz_id_riz;
go
create view info_o_predmetoch -- pre studentov
as 
	select p.zkratka as [zkratka], p.nazev as [název], v.jmeno + ' ' + v.prijmeni as [Jméno vyučujícího] 
		from predmet as p join vyucujici as v 
			on p.vyucujici_id_uc = v.id_uc;
go
create view zobraz_temy_prac -- pre vsetkych
as 
	select t.id, t.tema as [téma], v.jmeno + ' ' + v.prijmeni as [vypsal]
	from tema as t join 
		vyucujici as v on v.id_uc=t.vyucujici_id_uc
go
create view zobraz_info_o_pracach -- student, ucitel a ZP
as
	select s.jmeno + ' ' + s.prijmeni as [student], v.jmeno + ' ' + v.prijmeni as [učitel], t.tema as [téma], 
			zp.zadani as [zadání], thzp.datum_konani as [datum konání obhajoby]
	 from zaverecna_prace as zp join tema as t 
		on t.id=zp.tema_id join vyucujici as v 
		on v.id_uc=zp.vyucujici_id_uc join student as s
		on s.id_st=zp.student_id_st join prace_v_termine as pvt
		on zp.id_prac = pvt.zaverecna_prace_id_prac join termin_hodnoceni_ZP as thzp
		on thzp.id_hodp=pvt.termin_hodnoceni_ZP_id_hodp;
go
create view zobraz_terminy -- pre vsetkych
as
	select id_hodp, datum_konani from termin_hodnoceni_ZP;
go
create view zobraz_hodnotenia_zp -- student aj profesor
as 
	select s.id_st as [ID studenta], s.jmeno + ' ' + s.prijmeni as [Student], zp.id_prac as [ID práce],
			t.tema as [téma práce], st.znamka as [známka], st.popis as [popis], v.jmeno + ' '+ v.prijmeni as [hodnotící učitel]
	  from hodnotenie_ucitelov as hu 
			join termin_hodnoceni_ZP as thzp on thzp.id_hodp=hu.termin_hodnoceni_ZP_id_hodp
			join prace_v_termine as pvt on pvt.termin_hodnoceni_ZP_id_hodp=thzp.id_hodp
			join zaverecna_prace as zp on zp.id_prac=pvt.zaverecna_prace_id_prac 
			join tema as t on t.id = zp.tema_id
			join student as s on s.id_st=zp.student_id_st
			join vyucujici as v on hu.vyucujici_id_uc=v.id_uc
			join stupnice as st on st.id=hu.stupnice_id;
go
create view prace_studentov -- pre profesorov
as 
	select * from zaverecna_prace;
go
create view zobraz_terminy_zapoctov -- pre vsetkych
as
	select * from zapocet;
go
create view zobraz_predmety_a_zapocty
as
	select z.id_zap as [ID zápočtu],z.datum_konani as [dátum zápočtu], p.zkratka as [skratka predmetu], p.nazev as [názov]
	 from zapocet as z join predmety_na_zapoctoch as pnz
		on z.id_zap = pnz.zapocet_id_zap join predmet as p
		on p.zkratka=pnz.predmet_zkratka;
go
create view zobraz_predmety_a_skusky
as
	select z.id_zk as [ID skúšky],z.datum_konani as [dátum konania], p.zkratka as [skratka predmetu], p.nazev as [názov]
	 from zkouska as z join predmety_na_skuskach as pns
		on z.id_zk = pns.zkouska_id_zk join predmet as p
		on p.zkratka=pns.predmet_zkratka;
go
create view zobraz_prava_roc_uc_z -- ru, vyuc
as
	select pzap.rocnikovy_ucitel_id_ru as [ID ročníkového učiteľa], convert(varchar(4), z.id_zap) + ' ' + convert(varchar(11), z.datum_konani) + ' ' + z.misto_popis as [zápočet],
			ru.jmeno + ' ' + ru.prijmeni as [Ročníkový učitel], v.jmeno + ' ' + v.prijmeni as [právo udělil]
	 from pravo_zapoc as pzap join zapocet as z 
		on z.id_zap = pzap.zapocet_id_zap join vyucujici as v
		on v.id_uc=pzap.vyucujici_id_uc join rocnikovy_ucitel as ru
		on ru.id_ru=pzap.rocnikovy_ucitel_id_ru
		;
go
create view zobraz_prava_roc_uc_zk -- ru, vyuc
as
	select pzk.rocnikovy_ucitel_id_ru as [ID ročníkového učiteľa], convert(varchar(4), z.id_zk) + ' ' + convert(varchar(11), z.datum_konani) + ' ' + z.misto_popis as [zkouška],
		ru.jmeno + ' ' + ru.prijmeni as [Ročníkový učitel], v.jmeno + ' '+ v.prijmeni as [právo udělil]
	 from pravo_zk as pzk join vyucujici as v
	on pzk.vyucujici_id_uc =v.id_uc join zkouska as z
	on z.id_zk = pzk.zkouska_id_zk join rocnikovy_ucitel as ru
	on ru.id_ru = pzk.rocnikovy_ucitel_id_ru;
go
create view zobraz_komplex_inf_uc
as
	select v.jmeno + ' ' + v.prijmeni as [meno], stp.nazev as [názov programu],  u.nazev as [ústav], f.nazev as [fakulta], 
		dv.typ as [pozícia]
	 from vyucujici as v join druh_vyuc as dv
	on v.druh_vyuc_id = dv.id join  vyucujici_v_programe as vvp
	on vvp.vyucujici_id_uc = v.id_uc join st_program as stp
	on stp.id_sp = vvp.st_program_id_sp join ustav as u
	on u.nazev =stp.ustav_nazev join fakulta as f
	on f.id_fak = u.fakulta_id_fak;
go
create view dozor_pab
as
	select stp.nazev as [program], p.jmeno + ' ' + p.prijmeni as [dozorca] 
	from dozorcovia_programov as dp
		join pab as p on p.id_pab=dp.pab_id_pab 
		join st_program as stp on stp.id_sp=dp.st_program_id_sp;
go
-- procedures
--prijimacie konanie a vseobecne
create proc inputAddress -- vlozi adresu viazanu na studentovo id
@krajina varchar(100),
@mesto varchar(50),
@ulica varchar(100),
@psc varchar(7),
@student_id_st as int,
@errMsg as varchar(255) output
as
	declare @chkid as int;

	set @chkid = (select top 1 id_st from student where id_st=@student_id_st);
	if (not @chkid is null)
	begin
		insert into adresa(krajina, mesto, ulica, psc, student_id_st)
			values(@krajina, @mesto, @ulica, @psc, @student_id_st);
	end;
	else
	begin
		set @errMsg = 'Chyba zadane id nenajdene';
	end;
go
create proc makeLogin -- login je generovany studentovi
@pr as varchar(30),
@id as int,
@login as varchar(40) output
as
	set @login = 'x' + @pr + convert(varchar, floor(10*rand()))+ convert(varchar, @id);
	set @login = convert(varchar(40), @login);
go
create proc regStudent -- registruje studenta vykona vsetky kontroly atd.
-- osobne
@jmeno as varchar(20),
@prijmeni as varchar(30),
@vek as int,
@rodne_cislo as numeric(11),
@pohlavi as bit,
@vzdelanie as int,
-- adresa
@krajina as varchar(100),
@mesto as varchar(50),
@ulica as varchar(100),
@psc as varchar(7),
--dbg
@errorMsg as varchar(200) output
as
	declare @loginNew as varchar(40);
	declare @futureId as int;
	declare @chybaAdresa as varchar(255);
	if(ident_current('student')=1)
	begin
		set @futureId = ident_current('student');
	end;
	else
	begin
		set @futureId = ident_current('student') + 1;
	end;
	
	--select @futureId as buduce_id;
	exec makeLogin @prijmeni, @futureId, @login = @loginNew output;

	--select @loginNew as novy_login;
	begin try
		insert into student(login, jmeno, prijmeni, vek, rodne_cislo, pohlavi, vzdelani_id) 
			values (@loginNew, @jmeno, @prijmeni, @vek, @rodne_cislo, @pohlavi, @vzdelanie);
	END try
	begin catch
		set @errorMsg = (select error_message());
	end catch;
	--zadaj adresu
	if (@errorMsg is null)
	begin
		begin tran zadajAdresu
			exec inputAddress @krajina, @mesto, @ulica, @psc, @futureId, @errMsg = @errorMsg output;
			if (not @errorMsg is null)
			begin
				select @errorMsg as 'chyba v zadavani adresy';
			end;
			else
			begin
				select 'adresa ulozena';
				commit tran zadajAdresu;
			end;
	end;
go
create proc podatPrihlasku -- student podava prihlasku
@studentID as int,
@oborId as int,
@idriz as int,
@errMsg as varchar(255) output
as
	declare @chkid as int;
	declare @idrizchk as int;
	declare @idpr as int;
	
	declare poslednapri cursor scroll for select id_pr from prihlaska;
	--check if id exists
	set @chkid = (select top 1 id_st from student where id_st=@studentId);
	--check if rizeni in given date exists
	set @idrizchk = (select top 1 id_riz from prijmaci_riz where id_riz=@idriz);

	if (not @chkid is null)
	begin
		if (not @idrizchk is null)
		begin
			insert into prihlaska(student_id_st, st_obor_id_so)
				values(@studentID, @oborId);
			open poslednapri;
			fetch last from poslednapri into @idpr;
			insert into vysledky_prijmani(prihlaska_id_pr, prijmaci_riz_id_riz)
				values(@idpr, @idriz);
			close poslednapri;
			deallocate poslednapri;
		end;
		else
		begin
			set @errMsg = 'konanie v danom datume nieje';
		end;
	end;
	else
	begin
		set @errMsg = 'chyba zadane ID neexistuje';
	end;
go
create proc vypisPrijZ -- referentka vypisuje prijimiaci riz
@datumK as varchar(255),
@popis as varchar(1024),
@trvanie as time,
@casK as time,
@id_ref as int,
@errMsg as varchar(255) output
as
	declare @id_riz as int;
	declare prijmacky cursor scroll for select id_riz from prijmaci_riz;

	begin try
		insert into prijmaci_riz(datum_konani, popis_mista_konani, doba_trvani, cas_konania)
			values(convert(date, @datumK, 104), @popis, @trvanie, @casK);
		open prijmacky;
		fetch last from prijmacky into @id_riz;
		insert into referentka_prijZ(prijmaci_riz_id_riz, referentka_id_ref)
			values(@id_riz, @id_ref);
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;

	close prijmacky;
	deallocate prijmacky;
go
create proc vykonajPlatbu -- student plati
@ucel as varchar(50),
@vyska as int,
@id_st as int,
@datum_platby varchar(40) = NULL,
@override as bit=0, -- pretazit kkontrolu casom
@errMsg as varchar(255) output
as
	if(@override = 0)
	begin
		if(@ucel like 'ZS' and convert(date, getdate())<=convert(date, '15.11.'+convert(varchar(4), year(convert(date, getdate()))), 104)) -- over ci sedi semester
		begin
			if(@vyska <= 28000)
			begin
				begin try
					if(@datum_platby is null)
					begin
						insert into platby(ucel, vyska_platby, student_id_st)
							values(@ucel, @vyska, @id_st);
					end;
					else
					begin
						insert into platby(ucel, vyska_platby, student_id_st, datum_prijeti)
							values(@ucel, @vyska, @id_st, convert(date, @datum_platby, 104));
					end;
				end try
				begin catch
					set @errMsg = ERROR_MESSAGE();
				end catch;
			end;
			else
			begin
				set @errMsg = 'POZOR, Neplatna vyska platby pre zimny semester, odvolajte tranzakciu!';
			end;
		end;
		else if(@ucel like 'LS' and convert(date, getdate())<=convert(date, '15.04.'+convert(varchar(4), year(convert(date, getdate()))), 104))
		begin
			if(@vyska <= 10000)
			begin
				begin try
					if(@datum_platby is null)
					begin
						insert into platby(ucel, vyska_platby, student_id_st)
							values(@ucel, @vyska, @id_st);
					end;
					else
					begin
						insert into platby(ucel, vyska_platby, student_id_st, datum_prijeti)
							values(@ucel, @vyska, @id_st, convert(date, @datum_platby, 104));
					end;
				end try
				begin catch
					set @errMsg = ERROR_MESSAGE();
				end catch;
			end;
			else
			begin
				set @errMsg='POZOR, Neplatna vyska platby pre letny semester, odvolajte tranzakciu!';
			end;
		end;
		else if(@ucel like 'prihlaska')
		begin
			if(@vyska <= 400)
			begin
				begin try
					if(@datum_platby is null)
					begin
						insert into platby(ucel, vyska_platby, student_id_st)
							values(@ucel, @vyska, @id_st);
					end;
					else
					begin
						insert into platby(ucel, vyska_platby, student_id_st, datum_prijeti)
							values(@ucel, @vyska, @id_st, convert(date, @datum_platby, 104));
					end;
				end try
				begin catch
					set @errMsg = ERROR_MESSAGE();
				end catch;
			end;
			else
			begin
				set @errMsg = 'POZOR, Neplatna vyska platby pre prihlasku, odvolajte tranzakciu!';
			end;
		end;
		else
		begin
			set @errMsg = 'Platba v nespravnom obdobi';
		end;
	end;
	else
	begin
		if(@ucel like 'ZS') -- over ci sedi semester
		begin
			if(@vyska <= 28000)
			begin
				begin try
					if(@datum_platby is null)
					begin
						insert into platby(ucel, vyska_platby, student_id_st)
							values(@ucel, @vyska, @id_st);
					end;
					else
					begin
						insert into platby(ucel, vyska_platby, student_id_st, datum_prijeti)
							values(@ucel, @vyska, @id_st, convert(date, @datum_platby, 104));
					end;
				end try
				begin catch
					set @errMsg = ERROR_MESSAGE();
				end catch;
			end;
			else
			begin
				set @errMsg = 'POZOR, Neplatna vyska platby pre zimny semester, odvolajte tranzakciu!';
			end;
		end;
		else if(@ucel like 'LS')
		begin
			if(@vyska <= 10000)
			begin
				begin try
					if(@datum_platby is null)
					begin
						insert into platby(ucel, vyska_platby, student_id_st)
							values(@ucel, @vyska, @id_st);
					end;
					else
					begin
						insert into platby(ucel, vyska_platby, student_id_st, datum_prijeti)
							values(@ucel, @vyska, @id_st, convert(date, @datum_platby, 104));
					end;
				end try
				begin catch
					set @errMsg = ERROR_MESSAGE();
				end catch;
			end;
			else
			begin
				set @errMsg='POZOR, Neplatna vyska platby pre letny semester, odvolajte tranzakciu!';
			end;
		end;
		else if(@ucel like 'prihlaska')
		begin
			if(@vyska <= 400)
			begin
				begin try
					if(@datum_platby is null)
					begin
						insert into platby(ucel, vyska_platby, student_id_st)
							values(@ucel, @vyska, @id_st);
					end;
					else
					begin
						insert into platby(ucel, vyska_platby, student_id_st, datum_prijeti)
							values(@ucel, @vyska, @id_st, convert(date, @datum_platby, 104));
					end;
				end try
				begin catch
					set @errMsg = ERROR_MESSAGE();
				end catch;
			end;
			else
			begin
				set @errMsg = 'POZOR, Neplatna vyska platby pre prihlasku, odvolajte tranzakciu!';
			end;
		end;
		else
		begin
			set @errMsg = 'Platba v nespravnom obdobi';
		end;
	end;
go
create proc hodnoteniePrijmaciek -- referentka zadava hodnotenie prijimaciek
@hodnotenie as int,
@prihlaskaID as int,
@errMsg as varchar(255) output
as
	if(@hodnotenie >= 0)
	begin
		update vysledky_prijmani set hodnoceni = @hodnotenie where prihlaska_id_pr = @prihlaskaID;
	end;
	else
	begin
		set @errMsg = 'chyba hodnotenie nemoze byt zaporne';
	end;
go
create proc pridatKartuPredmetu
@jazyk_karty as varchar(2),
@zkratka as varchar(10),
@rocnik as int,
@semestr as varchar(2),
@kredity as int,
@ukonceni as varchar(5),
@jazyk as varchar(2),
@povinnost as int,
@id as int,
@popis as varchar(2048),
@errMsg as varchar(255) output
as
	if (@id in (select id_uc from vyucujici))
	begin
		begin try
			insert into karta_predmetu(lang, rocnik, semestr, kredity, ukonceni, jazyk, povinnost_id, predmet_zkratka, popis)
				values(@jazyk_karty, @rocnik, @semestr, @kredity, @ukonceni, @jazyk, @povinnost, @zkratka, @popis);
		end try
		begin catch
			set @errMsg = Error_message();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba uzivatel nema dostatocne opravnenie';
	end;
go
create proc zobrazGarantovePredmety -- konkretne garant
@id_uc as int,
@errMsg as varchar(255) output
as
	if(@id_uc in (select id_uc from vyucujici) and (select top 1 druh_vyuc_id from vyucujici where id_uc=@id_uc) = 2)
	begin
		begin try
			select p.zkratka, p.nazev from predmet as p where @id_uc=p.vyucujici_id_uc;
		end try
		begin catch
			set @errMsg=Error_Message();
		end catch;
	end
go
create proc zobrazUcitelovePredmety --generickejsia proc
@id as int,
@errMsg as varchar(255) output
as
	
	if(@id in (select id_uc from vyucujici))
	begin
		begin try
			select p.zkratka, p.nazev from predmet as p where @id=p.vyucujici_id_uc;
		end try
		begin catch
			set @errMsg=Error_Message();
		end catch;
	end;
go
create proc zobrazPredmRU -- rocnikovy ucitel
@id as int,
@errMsg as varchar(255) output
as
	if(@id in (select id from ucene_predmety))
	begin
		begin try
			select p.zkratka, p.nazev from ucene_predmety as up join predmet as p on p.zkratka=up.predmet_zkratka where @id=up.rocnikovy_ucitel_id_ru;
		end try
		begin catch
			set @errMsg=Error_Message();
		end catch;
	end;
go
create proc pridajUcenyPredmet -- rocnikovy ucitel
@id as int,
@predmZ as varchar(20),
@errMsg as varchar(255) output
as
	if (@id in (select id_ru from rocnikovy_ucitel))
	begin
		begin try
			insert into ucene_predmety(rocnikovy_ucitel_id_ru, predmet_zkratka)
				values(@id, @predmZ);
		end try
		begin catch 
			set @errMsg = Error_message();
		end catch;
	end;
	else
	begin
		set @errMsg= 'Chyba, nespravne ID';
	end;
go
create proc zobrazKartyMojichPredmetov
@id as int, 
@errMsg as varchar(255) output
as
	if (@id in (select id_uc from vyucujici))
	begin
		begin try
			select  p.nazev as [název předmětu], kp.lang as [jazyk karty], kp.jazyk as [jazyk přednášek], kp.kredity as [kredity], kp.semestr as [semestr],
					kp.ukonceni as [ukončení], pov.povinnost as [povinnost], kp.popis as [popis předmětu]
			from predmet as p join karta_predmetu as kp on p.zkratka=kp.predmet_zkratka
				join vyucujici as v on v.id_uc=p.vyucujici_id_uc join povinnost as pov
				on pov.id=kp.povinnost_id
			where v.id_uc=@id;
		end try
		begin catch
			set @errMsg = Error_message();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba uzivatel nema dostatocne opravnenie';
	end;
go
create proc vypis_temu_prace
@id as int,
@tema as varchar(255),
@errMsg as varchar(255) output
as
	if (@id in (select id_uc from vyucujici) and (select dv.typ from vyucujici as v join druh_vyuc as dv on dv.id=v.druh_vyuc_id where v.id_uc=@id) like 'garant')
	begin
		begin try
			insert into tema(tema, vyucujici_id_uc)
				values(@tema, @id);
		end try
		begin catch
			set @errMsg = Error_message();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba uzivatel nema dostatocne opravnenie';
	end;
go
create proc platby_studenta
@idSt as int, 
@errMsg as varchar(255) output
as
	if(@idSt in (select id_st from student))
	begin
		select * from platby where student_id_st = @idSt;
	end;
	else
	begin
		set @errMsg = 'Chyba studentove ID nenajdene';
	end;
go
create proc vypisTerminHodnZP
@id as int,
@datum as varchar(30),
@errMsg as varchar(255) output
as
	if (@id in (select id_uc from vyucujici) and (select dv.typ from vyucujici as v join druh_vyuc as dv on dv.id=v.druh_vyuc_id where v.id_uc=@id) like 'garant')
	begin
		begin try
			insert into termin_hodnoceni_ZP(datum_konani)
				values(convert(date, @datum, 104));
		end try
		begin catch
			set @errMsg = Error_message();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba uzivatel nema dostatocne opravnenie';
	end;
go
-- registracia delegacia
create procedure registrujPovinnePredmety -- vsetky predmety sa registruju pred zacatim ZS a to predmety v ZS aj LS
	@id_st as int,
	@curdate as varchar(255) = null, -- len ak nastaveny override
	@override as bit = 0, -- priznak pretazit pouzit custom date
	@errMsg as varchar(255) output
	as
	declare @zaplaceno as bit;
	declare @rocnik_st as int;
	declare @semestr_st as varchar(2);
	declare @datum_dnes as date;
	declare @datepart as int;
	declare @predmet_zkratka as varchar(20);
	declare @pov as varchar(9);
	begin
		set @zaplaceno = (select top 1 p.potvrzeno from student as s join platby as p on p.student_id_st=s.id_st 
							where p.ucel like 'ZS' or p.ucel like 'LS' and s.id_st=@id_st) 
		if (@zaplaceno is not null)
		begin
			if(@override = 0)
			begin
				if ((convert(date, getdate()) >= convert(date, '01.09.'+convert(varchar(4), year(convert(date, getdate()))), 104))
					and (convert(date, getdate()) <= convert(date, '01.10.'+convert(varchar(4), year(convert(date, getdate()))), 104))) -- ak by mal prist zimny semester
				begin
				set @rocnik_st = (select rocnik from student where id_st=@id_st);
				set @datepart = (select datepart(month, getdate()));
				if(@datepart <= 6)
				begin
					set @semestr_st = 'LS';	
				end;
				else
				begin
					set @semestr_st='ZS';
				end;

				-- nacteni predmetu z daneho semestru
				declare kurs cursor scroll for 
							select p.zkratka, pv.povinnost
								 from predmet as p join karta_predmetu as kp on p.zkratka=kp.predmet_zkratka
									join povinnost as pv on pv.id=kp.povinnost_id 
									where kp.rocnik=@rocnik_st and kp.semestr=@semestr_st;
									
		
				--registrace povinnych
				open kurs;
				fetch next from kurs into @predmet_zkratka, @pov;
				while @@fetch_status=0
				begin
					if (@pov like 'P')
					begin
						insert into predmet_student (student_id_st, predmet_zkratka) 
							values (@id_st, @predmet_zkratka)
					end;
					fetch next from kurs into @predmet_zkratka, @pov;
				end
				close kurs
				deallocate kurs
			end;
				else if ((convert(date, getdate()) >= convert(date, '01.02.'+convert(varchar(4), year(convert(date, getdate()))), 104))
					and (convert(date, getdate()) <= convert(date, '01.03.'+convert(varchar(4), year(convert(date, getdate()))), 104))) -- ak by mal prist letny semester
				begin
				set @rocnik_st = (select rocnik from student where id_st=@id_st);
				set @datepart = (select datepart(month, getdate()));
				if(@datepart <= 6)
				begin
					set @semestr_st = 'LS';	
				end;
				else
				begin
					set @semestr_st='ZS';
				end;

				-- nacteni predmetu z daneho semestru
				declare kurs cursor scroll for 
							select p.zkratka, pv.povinnost
								 from predmet as p join karta_predmetu as kp on p.zkratka=kp.predmet_zkratka
									join povinnost as pv on pv.id=kp.povinnost_id 
									where kp.rocnik=@rocnik_st and kp.semestr=@semestr_st;
		
				--registrace povinnych

				open kurs;
				fetch next from kurs into @predmet_zkratka, @pov;
				while @@fetch_status=0
				begin
					if (@pov like 'P')
					begin
						insert into predmet_student (student_id_st, predmet_zkratka) 
							values (@id_st, @predmet_zkratka)
					end;
					fetch next from kurs into @predmet_zkratka, @pov;
				end
				close kurs
				deallocate kurs
			end;
				else
				begin
				set @errMsg = 'Chyba datum registracie';
			end;
			end;
			else
			begin
				if ((convert(date, @curdate, 104) >= convert(date, '01.09.'+convert(varchar(4), year(convert(date, getdate()))), 104))
					and (convert(date, @curdate, 104) <= convert(date, '01.10.'+convert(varchar(4), year(convert(date, getdate()))),104)))
				begin
					set @rocnik_st = (select rocnik from student where id_st=@id_st);
					set @datepart = (select datepart(month, convert(date, @curdate, 104)));
					if(@datepart <= 6)
					begin
						set @semestr_st = 'LS';	
					end;
					else
					begin
						set @semestr_st='ZS';
					end;

					-- nacteni predmetu z daneho semestru
					declare kurs cursor scroll for 
							select p.zkratka, pv.povinnost
								 from predmet as p join karta_predmetu as kp on p.zkratka=kp.predmet_zkratka
									join povinnost as pv on pv.id=kp.povinnost_id 
									where kp.rocnik=@rocnik_st and kp.semestr=@semestr_st;
		
					--registrace povinnych
					open kurs;
					fetch next from kurs into @predmet_zkratka, @pov;
					while @@fetch_status=0
					begin
						if (@pov like 'P')
						begin
							insert into predmet_student (student_id_st, predmet_zkratka) 
								values (@id_st, @predmet_zkratka)
						end;
						fetch next from kurs into @predmet_zkratka, @pov;
					end
					close kurs
					deallocate kurs
				end;
				else if ((convert(date, @curdate, 104) >= convert(date, '01.02.'+convert(varchar(4), year(convert(date, getdate()))), 104))
					and (convert(date, @curdate, 104) <= convert(date, '01.03.'+convert(varchar(4), year(convert(date, getdate()))), 104))) -- ak by mal prist letny semester
				begin
					set @rocnik_st = (select rocnik from student where id_st=@id_st);
					set @datepart = (select datepart(month, convert(date, @curdate, 104)));
					if(@datepart <= 6)
					begin
						set @semestr_st = 'LS';	
					end;
					else
					begin
						set @semestr_st='ZS';
					end;

						-- nacteni predmetu z daneho semestru
					declare kurs cursor scroll for 
							select p.zkratka, pv.povinnost
								 from predmet as p join karta_predmetu as kp on p.zkratka=kp.predmet_zkratka
									join povinnost as pv on pv.id=kp.povinnost_id 
									where kp.rocnik=@rocnik_st and kp.semestr=@semestr_st;
		
					--registrace povinnych

					open kurs;
					fetch next from kurs into @predmet_zkratka, @pov;
					while @@fetch_status=0
					begin
						if (@pov like 'P')
						begin
							insert into predmet_student (student_id_st, predmet_zkratka) 
								values (@id_st, @predmet_zkratka)
						end;
						fetch next from kurs into @predmet_zkratka, @pov;
					end
					close kurs
					deallocate kurs
				end;
				else
				begin
					set @errMsg = 'Chyba datum registracie 2';
				end;
			end;
		end;
		else
		begin
			set @errMsg = 'Chyba predmety nemozno registrovat, pretoze nieje registrovana platba za semester';
		end
	end
go
create procedure registrujPredmet -- pv, V, S
	@id_st as int,
	@zkr as varchar(20),
	@errMsg as varchar(255) output
	as
	declare @zaplaceno as bit;
	
	begin
		set @zaplaceno = (select top 1 p.potvrzeno from student as s join platby as p on p.student_id_st=s.id_st 
							where p.ucel like 'ZS' or p.ucel like 'LS' and s.id_st=@id_st) 
		if (@zaplaceno is not null)
		begin
			insert into predmet_student (student_id_st, predmet_zkratka) 
									values (@id_st, @zkr);
		end;
		else
		begin
			set @errMsg = 'Chyba, nezaplateny semmester';
		end;
	end;
go
create procedure delegace_prav_zk_roc_uc
	@id_uc as int,
	@id_ru as int,
	@id_zk as int
	as
	declare @pravo_zk_id as int
	begin
		if(@id_uc in (select p.vyucujici_id_uc from predmet as p join predmety_na_skuskach as pns on p.zkratka=pns.predmet_zkratka
			where pns.zkouska_id_zk=@id_zk))
		begin
			set @pravo_zk_id = (select top 1 id from pravo_zk where zkouska_id_zk=@id_zk and vyucujici_id_uc=@id_uc and rocnikovy_ucitel_id_ru=@id_ru);
			if (@pravo_zk_id is null)
			begin
				insert into pravo_zk (zkouska_id_zk, vyucujici_id_uc, rocnikovy_ucitel_id_ru) values (@id_zk, @id_uc, @id_ru)
			end
			else
			begin
				print 'Pravo je jiz delegovano.';
			end
		end;
	end
go
create procedure delegace_prav_zap_roc_uc
	@id_uc as int,
	@id_ru as int,
	@id_zap as int
	as
	declare @pravo_zap_id as int
	begin
		if(@id_uc in (select p.vyucujici_id_uc from predmet as p join predmety_na_zapoctoch as pnz on p.zkratka=pnz.predmet_zkratka
			where pnz.zapocet_id_zap=@id_zap))
		begin
			set @pravo_zap_id = (select top 1 id from pravo_zapoc where zapocet_id_zap=@id_zap and vyucujici_id_uc=@id_uc and rocnikovy_ucitel_id_ru=@id_ru);
			if (@pravo_zap_id is null)
			begin
				insert into pravo_zapoc(zapocet_id_zap, vyucujici_id_uc, rocnikovy_ucitel_id_ru) values (@id_zap, @id_uc, @id_ru);
			end
			else
			begin
				print 'Pravo je jiz delegovano.';
			end
		end;
	end
go
create procedure vypis_pravomoci_ru
	@roc_uc_id as int
	as
	begin
		select ru.jmeno + ' ' + ru.prijmeni as "Jméno a přijmení", pred.nazev
				from rocnikovy_ucitel ru join pravo_zk on ru.id_ru=pravo_zk.rocnikovy_ucitel_id_ru
					join zkouska zk on zk.id_zk=pravo_zk.zkouska_id_zk
					join predmety_na_skuskach pred_zk on zk.id_zk=pred_zk.zkouska_id_zk
					join predmet pred on pred.zkratka=pred_zk.predmet_zkratka
				where ru.id_ru=@roc_uc_id;
	end
go
-- zaverecna praca
create proc vyberPracu
@idSt as int,
@idTema as int, 
@zadani as varchar(100),
@idUc as int = null,
@datum as varchar(20) = null,
@errMsg as varchar(255) output
as
	begin try
		if ((select top 1 rocnik from student where id_st=@idSt)=2)
		begin
			if(@idUc is null)
			begin
				set @idUc = (select v.id_uc from vyucujici as v join tema as t on t.vyucujici_id_uc=v.id_uc
								where t.id=@idTema);
			end;
			if (@datum is null)
			begin
				insert into zaverecna_prace(student_id_st, vyucujici_id_uc, tema_id, datum_zverejneni, zadani)
					values(@idSt, @idUc, @idTema, convert(date, getdate(), 101), @zadani);
			end;	
			else
			begin
				insert into zaverecna_prace(student_id_st, vyucujici_id_uc, tema_id, datum_zverejneni, zadani)
					values(@idSt, @idUc, @idTema, convert(date, @datum, 104), @zadani);
			end;
		end;
	end try
	begin catch
		set @errMsg = ERROR_MESSAGE();
	end catch;
go
create proc vyberTermin
@idSt as int,
@idPrac as int, 
@idTerm as int,
@errMsg as varchar(255) output
as
	if (@idSt in (select s.id_st from student as s))
	begin
		if (@idPrac in (select p.id_prac from zaverecna_prace as p join student as s on s.id_st=p.student_id_st))
		begin
			begin try
				insert into prace_v_termine(zaverecna_prace_id_prac, termin_hodnoceni_ZP_id_hodp)
					values(@idPrac, @idTerm);
			end try
			begin catch
				set @errMsg = ERROR_MESSAGE();
			end catch;
		end;
		else
		begin
			set @errMsg = 'ID prace nenajdene';
		end;
	end;
	else
	begin
		set @errMsg = 'Studentovo ID nenajdene';
	end;
go
create proc zadaj_hodnotenie_zp
@idUc as int,
@idStupnice as int,
@idHodp as int,
@errMsg as varchar(255) output
as
	if ((@idUc in (select id_uc from vyucujici)) and ((select dv.typ from vyucujici as v join druh_vyuc as dv on dv.id=v.druh_vyuc_id where v.id_uc=@idUc) like 'garant'))
	begin	
		begin try
			insert into hodnotenie_ucitelov(stupnice_id, vyucujici_id_uc, termin_hodnoceni_zp_id_hodp)
				values(@idStupnice, @idUc, @idHodp);
		end try
		begin catch
			set @errMsg = Error_message();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba uzivatel nema dostatocne opravnenie';
	end;
go
create proc zobraz_studentove_hodnotenie
@idSt as int,
@errMsg as varchar(255) output
as
	if(@idSt in (select id_st from student))
	begin
		select * from zobraz_hodnotenia_zp where [ID studenta]=@idSt;
	end;
	else
	begin
		set @errMsg = 'Studentove ID nenajdene';
	end;
go
create proc zobrazZpStudenta
@idSt as int,
@errMsg as varchar(255) output
as
	if(@idSt in (select id_st from student))
	begin
		select * from zaverecna_prace where student_id_st=@idSt;
	end;
	else
	begin
		set @errMsg = 'Studentove ID nenajdene';
	end;
go
create proc getIdPraceStudenta
@idSt as int,
@idPr as int output,
@errMsg as varchar(255) output
as
	if(@idSt in (select id_st from student))
	begin
		set @idPr = (select id_prac from zaverecna_prace where student_id_st=@idSt);
	end;
	else
	begin
		set @errMsg = 'Studentove ID nenajdene';
	end;
go
create proc detailZPStudenta
@idSt as int,
@errMsg as varchar(255) output
as
	if(@idSt in (select id_st from student))
	begin
		select zp.id_prac, zp.datum_zverejneni, zp.zadani, thzp.datum_konani
			 from zaverecna_prace as zp join prace_v_termine as pvt on zp.id_prac=pvt.zaverecna_prace_id_prac
				join termin_hodnoceni_ZP as thzp on thzp.id_hodp=pvt.termin_hodnoceni_ZP_id_hodp;
	end;
	else
	begin
		set @errMsg = 'Studentove ID nenajdene';
	end;
go
create proc getHodpOfZP
@idSt as int,
@idHodp as int output,
@errMsg as varchar(255) output
as
	if(@idSt in (select id_st from student))
	begin
		set @idHodp = (select id_hodp from termin_hodnoceni_zp as thzp join prace_v_termine as pvt
						on thzp.id_hodp=pvt.termin_hodnoceni_ZP_id_hodp join zaverecna_prace as zp
						on zp.id_prac=pvt.zaverecna_prace_id_prac join student as s 
						on zp.student_id_st=s.id_st
						where s.id_st=@idSt
						);
	end;
	else
	begin
		set @errMsg = 'Studentove ID nenajdene';
	end;
go
--zapocet
create proc vypisTerminZapoctu -- len ak vypisuje vyucujici
@id as int,
@datum as varchar(255),
@popisMiesta as varchar(255),
@zkratka as varchar(20),
@errMsg as varchar(255) output
as
	declare @idZap as int;
	if ((@id in (select id_uc from vyucujici)) and (@zkratka in (select zkratka from predmet where vyucujici_id_uc=@id)))
	begin
		if((convert(date, @datum, 104) >= convert(date, '01.10.'+convert(varchar(4), year(convert(date, getdate()))), 104))
			and (convert(date, @datum, 104) <= convert(date, '31.01.'+convert(varchar(4), convert(int, year(convert(date, getdate())))+1), 104)))
		begin
			insert into zapocet(datum_konani, misto_popis, vyucujici_id_uc)
				values(convert(date, @datum, 104), @popisMiesta, @id);
				-- vlozit do predmetov na zapoctoch
			declare kurz cursor scroll for select id_zap from zapocet;
			open kurz
			fetch last from kurz into @idZap;
			
			insert into predmety_na_zapoctoch(zapocet_id_zap, predmet_zkratka)
				values(@idZap, @zkratka);
			close kurz
			deallocate kurz;
		end;
		else if((convert(date, @datum, 104) >= convert(date, '01.04.'+convert(varchar(4), year(convert(date, getdate()))), 104))
			and (convert(date, @datum, 104) <= convert(date, '31.07.'+convert(varchar(4), year(convert(date, getdate()))), 104)))
		begin
			insert into zapocet(datum_konani, misto_popis, vyucujici_id_uc)
				values(convert(date, @datum, 104), @popisMiesta, @id);
			declare kurz cursor scroll for select id_zap from zapocet;
			open kurz
			fetch last from kurz into @idZap;
			
			insert into predmety_na_zapoctoch(zapocet_id_zap, predmet_zkratka)
				values(@idZap, @zkratka);
			close kurz
			deallocate kurz;
		end;
	end;
	else
	begin
		set @errMsg = 'Chyba nedostatocne privilegium';
	end;
go
create proc registrujNaZapocet -- musi byt viazane aj podmienkou, ak ma student dany predmet zapisany
@idSt as int,
@idTermin as int, 
@errMsg as varchar(255) output
as
	declare @zistiPokusy as int;
	declare @idStup as int;
	declare @predmZ as varchar(20);
	if (@idSt in (select s.id_st from student as s))
	begin
	
		set @predmZ = (select p.zkratka from zapocet as z 
						join predmety_na_zapoctoch as pnz on pnz.zapocet_id_zap = z.id_zap 
						join predmet as p on p.zkratka=pnz.predmet_zkratka
						where z.id_zap = @idTermin);
		if(@predmZ in (select predmet_zkratka from predmet_student where student_id_st=@idSt))
		begin
			set @zistiPokusy = (select max(sz.pokus) from stud_zap as sz join zapocet as z on sz.zapocet_ID_zap=z.id_zap 
					join predmety_na_zapoctoch as pnz on pnz.zapocet_id_zap = z.id_zap 
					join predmet as p on pnz.predmet_zkratka=p.zkratka
					where @idSt = sz.student_ID_st and p.zkratka=@predmZ);
			set @idStup = (select top 1 hz.stupnice_id from stud_zap as sz join zapocet as z on sz.zapocet_ID_zap=z.id_zap 
							join predmety_na_zapoctoch as pnz on pnz.zapocet_id_zap = z.id_zap
							join predmet as p on pnz.predmet_zkratka=p.zkratka
							join hodnotenie_zap as hz on hz.zapocet_id_zap=z.id_zap
							where @idSt = sz.student_ID_st and p.zkratka=@predmZ);

			if(@zistiPokusy < 2 and not @zistiPokusy is null)
			begin
				if(@idStup = 6) -- len ak F na zapocte tak moze ist opravovat
				begin
					if(@zistiPokusy = 1)
					begin
						insert into stud_zap(pokus, student_ID_st, zapocet_ID_zap)
							values(2, @idSt, @idTermin);
					end;
					else
					begin
						insert into stud_zap(pokus, student_ID_st, zapocet_ID_zap)
							values(1, @idSt, @idTermin);
					end;
				end;
				else
				begin
					set @errMsg = 'Nieje mozne sa registrovat na termin, student dosiahol max. pocet pokusov';
				end;
			end;
			else
			begin
				insert into stud_zap(pokus, student_ID_st, zapocet_ID_zap)
							values(1, @idSt, @idTermin);
			end;
		end;
		else
		begin
			set @errMsg = 'Predmet nenajdeny';
		end;
	end;
	else
	begin
		set @errMsg = 'Studentovo ID nenajdene';
	end;
go
create proc zapoctyStudenta
@idSt as int,
@errMsg as varchar(255) output
as
	if (@idSt in (select s.id_st from student as s))
	begin
		select * from stud_zap where student_ID_st=@idSt;
	end;
	else
	begin
		set @errMsg = 'Chyba zadane ID nenajdene';
	end;
go
create proc ohodnotZapV -- hodnotenie vklada vyucujici
@idUc as int,
@idZapTerm as int,
@idSt as int,
@idStup as int,
@errMsg as varchar(255) output
as
	if(@idUc in (select vyucujici_id_uc from predmet where vyucujici_id_uc=@idUc))
	begin
		begin try	
			insert into hodnotenie_zap(vyucujici_id_uc, zapocet_id_zap, student_id_st, stupnice_id, rocnikovy)
				values(@idUc, @idZapTerm, @idSt, @idStup, 0);
		end try
		begin catch
			set @errMsg = ERROR_MESSAGE();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba zadane ID nenajdene';
	end;
go
create proc ohodnotZapRU -- hodnotenie vklada RU, robi sa check ci ma privilegium
@idRu as int,
@idZapTerm as int,
@idSt as int,
@idStup as int,
@errMsg as varchar(255) output
as
	if(@idRu in (select rocnikovy_ucitel_id_ru from pravo_zapoc where rocnikovy_ucitel_id_ru=@idRu)) -- musi mat privilegia
	begin
		begin try	
			insert into hodnotenie_zap(vyucujici_id_uc, zapocet_id_zap, student_id_st, stupnice_id, rocnikovy)
				values(@idRu, @idZapTerm, @idSt, @idStup, 1);
		end try
		begin catch
			set @errMsg = ERROR_MESSAGE();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba zadane ID nema dostatocne privilegia';
	end;
go
create proc vysledkyZap
@idSt as int,
@idZap as int,
@errMsg as varchar(255) output
as
	declare @rocnikovy as bit;
	if(@idSt in (select student_id_st from hodnotenie_zap where zapocet_id_zap=@idZap and student_id_st=@idSt))
	begin
		declare cur cursor scroll for select rocnikovy from hodnotenie_zap where zapocet_id_zap=@idZap and student_id_st=@idSt;
		open cur;
		fetch last from cur into @rocnikovy;
		close cur;
		deallocate cur;
		if((not @rocnikovy is null) and (@rocnikovy <> 0))
		begin
			select ru.jmeno + ' ' + ru.prijmeni as [ročníkový učiteľ], p.nazev [název předmětu],
				z.datum_konani [datum], s.znamka as [známka], s.popis as [popis] 
			from hodnotenie_zap as hz join rocnikovy_ucitel as ru on ru.id_ru = hz.vyucujici_id_uc
			join zapocet as z on z.id_zap = hz.zapocet_id_zap join stupnice as s on s.id = hz.stupnice_id
			join predmety_na_zapoctoch as pnz on pnz.zapocet_id_zap = z.id_zap join predmet as p on
			p.zkratka=pnz.predmet_zkratka
			where hz.zapocet_id_zap=@idZap and hz.student_id_st=@idSt;
		end;
		else
		begin
			select v.jmeno + ' ' + v.prijmeni as [vyučující], p.nazev [název předmětu],
				z.datum_konani [datum], s.znamka as [známka], s.popis as [popis] 
			from hodnotenie_zap as hz join vyucujici as v on v.id_uc = hz.vyucujici_id_uc
			join zapocet as z on z.id_zap = hz.zapocet_id_zap join stupnice as s on s.id = hz.stupnice_id
			join predmety_na_zapoctoch as pnz on pnz.zapocet_id_zap = z.id_zap join predmet as p on
			p.zkratka=pnz.predmet_zkratka
			where hz.zapocet_id_zap=@idZap and hz.student_id_st=@idSt;
		end;
	end;
	else
	begin
		set @errMsg = 'Hodnotenie nenajdene';
	end;
go
--skuska
create proc vypisTerminSkusky
@id as int,
@datum as varchar(255),
@popisMiesta as varchar(255),
@zkratka as varchar(20),
@errMsg as varchar(255) output
as
	declare @idZk as int;
	if ((@id in (select id_uc from vyucujici)) and (@zkratka in (select zkratka from predmet where vyucujici_id_uc=@id)))
	begin
		if((convert(date, @datum, 104) >= convert(date, '01.02.'+convert(varchar(4), convert(int, year(convert(date, getdate())))+1), 104))
			and (convert(date, @datum, 104) <= convert(date, '31.03.'+convert(varchar(4), convert(int, year(convert(date, getdate())))+1), 104)))
		begin
			insert into zkouska(datum_konani, misto_popis, vyucujici_id_uc)
				values(convert(date, @datum, 104), @popisMiesta, @id);
				-- vlozit do predmetov na zapoctoch
			declare kurz cursor scroll for select id_zk from zkouska;
			open kurz
			fetch last from kurz into @idZk;
			
			insert into predmety_na_skuskach(zkouska_id_zk, predmet_zkratka)
				values(@idZk, @zkratka);
			close kurz
			deallocate kurz;
		end;
		else if((convert(date, @datum, 104) >= convert(date, '01.08.'+convert(varchar(4), year(convert(date, getdate()))), 104))
			and (convert(date, @datum, 104) <= convert(date, '30.09.'+convert(varchar(4), year(convert(date, getdate()))), 104)))
		begin
			insert into zkouska(datum_konani, misto_popis, vyucujici_id_uc)
				values(convert(date, @datum, 104), @popisMiesta, @id);
			declare kurz cursor scroll for select id_zk from zkouska;
			open kurz
			fetch last from kurz into @idZk;
			
			insert into predmety_na_skuskahc(zkouska_id_zk, predmet_zkratka)
				values(@idZk, @zkratka);
			close kurz
			deallocate kurz;
		end;
	end;
	else
	begin
		set @errMsg = 'Chyba nedostatocne privilegium';
	end;
go
create proc registrujNaSkusku
@idSt as int,
@idTermin as int, 
@errMsg as varchar(255) output
as
	declare @zistiPokusy as int;
	declare @idStup as int;
	declare @predmZ as varchar(20);
	declare @maZapocet as int;
	declare kur cursor scroll for select hz.stupnice_id from hodnotenie_zap as hz join stupnice as s on hz.stupnice_id=s.id 
						where hz.student_id_st=@idSt;
			
	if (@idSt in (select s.id_st from student as s))
	begin
		set @predmZ = (select p.zkratka from zkouska as z 
						join predmety_na_skuskach as pns on pns.zkouska_id_zk = z.id_zk 
						join predmet as p on p.zkratka=pns.predmet_zkratka
						where z.id_zk=@idTermin);
		open kur;
		fetch last from kur into @maZapocet;--musi to byt posledne vzdy
		close kur;
		deallocate kur;
		if(@predmZ in (select predmet_zkratka from predmet_student where student_id_st=@idSt))--ma ho zapisany?
		begin
			set @zistiPokusy = (select max(sz.pokus) from stud_zk as sz join zkouska as z on sz.zkouska_id_zk=z.id_zk 
					join predmety_na_skuskach as pns on pns.zkouska_id_zk = z.id_zk
					join predmet as p on pns.predmet_zkratka=p.zkratka
					where @idSt = sz.student_ID_st and p.zkratka=@predmZ);--kolko uz mal pokusov
			if(@maZapocet < 6)
			begin
				set @idStup = (select top 1 hz.stupnice_id from stud_zk as sz join zkouska as z on sz.zkouska_ID_zk=z.id_zk
								join predmety_na_skuskach as pns on pns.zkouska_id_zk = z.id_zk
								join predmet as p on pns.predmet_zkratka=p.zkratka
								join hodn_zk as hz on hz.zkouska_id_zk=z.id_zk
								where @idSt = sz.student_ID_st and p.zkratka=@predmZ); -- aku dostal predtym znamku
				if(@zistiPokusy < 2 and not @zistiPokusy is null)
				begin
					if(@idStup = 6) -- len ak F na skuske tak moze ist opravovat
					begin
						if(@zistiPokusy = 1)
						begin
							insert into stud_zk(pokus, student_ID_st, zkouska_ID_zk)
								values(2, @idSt, @idTermin);
						end;
						else
						begin
							insert into stud_zk(pokus, student_ID_st, zkouska_ID_zk)
								values(1, @idSt, @idTermin);
						end;
					end;
					else
					begin
						set @errMsg = 'Nieje mozne sa registrovat na termin, student dosiahol max. pocet pokusov';
					end;
				end;
				else
				begin
					if(@maZapocet < 6)
					begin
						insert into stud_zk(pokus, student_ID_st, zkouska_ID_zk)
									values(1, @idSt, @idTermin);
					end;
					else
					begin
						set @errMsg = 'student ktory nema zapocet sa nemoze na skusku registrovat';
					end;
				end;
			end;
			else
			begin
				set @errMsg = 'student ktory nema zapocet sa nemoze na skusku registrovat';
			end;
		end;
	end;
	else
	begin
		set @errMsg = 'Studentovo ID nenajdene';
	end;
go
create proc skuskyStudenta
@idSt as int,
@errMsg as varchar(255) output
as
	if (@idSt in (select s.id_st from student as s))
	begin
		select * from stud_zk where student_ID_st=@idSt;
	end;
	else
	begin
		set @errMsg = 'Chyba zadane ID nenajdene';
	end;
go
create proc ohodnotZkV -- skusku hodnoti vyucujuci
@idUc as int,
@idZkTerm as int,
@idSt as int,
@idStup as int,
@errMsg as varchar(255) output
as
	if(@idUc in (select vyucujici_id_uc from predmet where vyucujici_id_uc=@idUc))
	begin
		begin try	
			insert into hodn_zk(vyucujici_id_uc, zkouska_id_zk, student_id_st, stupnice_id, rocnikovy)
				values(@idUc, @idZkTerm, @idSt, @idStup, 0);
		end try
		begin catch
			set @errMsg = ERROR_MESSAGE();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba zadane ID nenajdene';
	end;
go
create proc ohodnotZkRu
@idRu as int,
@idZkTerm as int,
@idSt as int,
@idStup as int,
@errMsg as varchar(255) output
as
	if(@idRu in (select rocnikovy_ucitel_id_ru from pravo_zk where rocnikovy_ucitel_id_ru=@idRu)) -- musi mat privilegia
	begin
		begin try	
			insert into hodn_zk(vyucujici_id_uc, zkouska_id_zk, student_id_st, stupnice_id, rocnikovy)
				values(@idRu, @idZkTerm, @idSt, @idStup, 1);
		end try
		begin catch
			set @errMsg = ERROR_MESSAGE();
		end catch;
	end;
	else
	begin
		set @errMsg = 'Chyba zadane ID nema dostatocne privilegia';
	end;
go
create proc vysledkyZk
@idSt as int,
@idZk as int,
@errMsg as varchar(255) output
as
	declare @rocnikovy as bit;
	if(@idSt in (select student_id_st from hodn_zk where zkouska_id_zk=@idZk and student_id_st=@idSt))
	begin
		declare cur cursor scroll for select rocnikovy from hodn_zk where zkouska_id_zk=@idZk and student_id_st=@idSt;
		open cur;
		fetch last from cur into @rocnikovy;
		close cur;
		deallocate cur;
		if((not @rocnikovy is null) and (@rocnikovy <> 0))
		begin
			select ru.jmeno + ' ' + ru.prijmeni as [ročníkový učiteľ], p.nazev [název předmětu],
				z.datum_konani [datum], s.znamka as [známka], s.popis as [popis] 
			from hodn_zk as hz join rocnikovy_ucitel as ru on ru.id_ru = hz.vyucujici_id_uc
			join zkouska as z on z.id_zk = hz.zkouska_id_zk join stupnice as s on s.id = hz.stupnice_id
			join predmety_na_skuskach as pns on pns.zkouska_id_zk= z.id_zk join predmet as p on
			p.zkratka=pns.predmet_zkratka
			where hz.zkouska_id_zk=@idZk and hz.student_id_st=@idSt;
		end;
		else
		begin
			select v.jmeno + ' ' + v.prijmeni as [vyučující], p.nazev [název předmětu],
				z.datum_konani [datum], s.znamka as [známka], s.popis as [popis] 
			from hodn_zk as hz join vyucujici as v on v.id_uc = hz.vyucujici_id_uc
			join zkouska as z on z.id_zk = hz.zkouska_id_zk join stupnice as s on s.id = hz.stupnice_id
			join predmety_na_skuskach as pns on pns.zkouska_id_zk = z.id_zk join predmet as p on
			p.zkratka=pns.predmet_zkratka
			where hz.zkouska_id_zk=@idZk and hz.student_id_st=@idSt;
		end;
	end;
	else
	begin
		set @errMsg = 'Hodnotenie nenajdene';
	end;
go
-- pab dohlad
create proc zadelDozor
@id1 as int, 
@id2 as int,
@id3 as int,
@id4 as int,
@idStP as int,
@errMsg as varchar(255) output
as
	if(@idStP in (select id_sp from st_program))
	begin
		if(@id1 in (select id_pab from pab) and @id2 in (select id_pab from pab) 
			and @id3 in (select id_pab from pab) and @id4 in (select id_pab from pab))
		begin
			insert into dozorcovia_programov (st_program_id_sp, pab_id_pab)
				values(@idStP,@id1);
			insert into dozorcovia_programov (st_program_id_sp, pab_id_pab)
				values(@idStP,@id2);
			insert into dozorcovia_programov (st_program_id_sp, pab_id_pab)
				values(@idStP,@id3);
			insert into dozorcovia_programov (st_program_id_sp, pab_id_pab)
				values(@idStP,@id4);
		end;
	end;
	else
	begin
		set @errMsg = 'Zadane ID programu nenajdene';
	end;
go
--koniec
create proc ukonci_studium
@idSt as int,
@errMsg as varchar(255) output
as
	declare @znZP as int;
	declare @sumKredity as int;
	declare @checkSum as int;
	set @sumKredity = 0;
	set @checkSum = 0;

	if(@idSt in (select id_st from student))
	begin
		set @znZP= (select st.znamka from hodnotenie_ucitelov as hu 
			join termin_hodnoceni_ZP as thzp on thzp.id_hodp=hu.termin_hodnoceni_ZP_id_hodp
			join prace_v_termine as pvt on pvt.termin_hodnoceni_ZP_id_hodp=thzp.id_hodp
			join zaverecna_prace as zp on zp.id_prac=pvt.zaverecna_prace_id_prac 
			join tema as t on t.id = zp.tema_id
			join student as s on s.id_st=zp.student_id_st
			join vyucujici as v on hu.vyucujici_id_uc=v.id_uc
			join stupnice as st on st.id=hu.stupnice_id
			where s.id_st=@idSt);
			if(@znZP<6 and (not @znZP is null))
			begin
				set @sumKredity = (select sum(kp.kredity)
					from hodn_zk as hk 
					join stupnice as st on st.id = hk.stupnice_id
					join zkouska as z on z.id_zk = hk.zkouska_id_zk
					join predmety_na_skuskach as pns on pns.zkouska_id_zk = z.id_zk
					join predmet as p on p.zkratka = pns.predmet_zkratka
					join karta_predmetu as kp on kp.predmet_zkratka=p.zkratka
					where hk.student_id_st = @idSt and st.id<6 and kp.lang like 'EN');

				set @checkSum = (select sum(kp.kredity) from predmet as p join karta_predmetu as kp on p.zkratka=kp.predmet_zkratka
					where kp.lang like 'EN');
					if(@sumKredity = @checkSum)
					begin
						update student set dat_ukonceni_stud=getdate() where id_st=@idSt;
					end;
					else
					begin
						set @errMsg = 'Studium nieje mozne regulerne skoncit, koli nedostatku kreditov';
					end;
			end;
			else
			begin
				set @errMsg = 'Ukoncenie studia nieje mozne, znamka zaverecnej prace: ' + convert(varchar(2), @znZP);
			end;
	end;
	else
	begin
		set @errMsg = 'ID studenta nenajdene';
	end;
go
----------------------------------------------------------------------------------------------
-- triggers
create trigger platba
	on platby
	for insert, update
	as
		declare @val as int;
		declare @uc as varchar(50);
		declare @id_platby as int;
		declare @suma_platieb as int;
		declare @datPrijatia as date;
		declare @idSt as int;

		set @val = (select top 1 vyska_platby from inserted);
		set @uc = (select top 1 ucel from inserted);
		set @id_platby = (select top 1 id from inserted);
		set @datPrijatia = (select top 1 i.datum_prijeti from inserted as i);
		set @idSt = (select i.student_id_st from inserted as i);

		if(@uc like 'prihlaska' and @val = 400)--neuvazujme, ze by niekto poslal viac
		begin
			update platby set potvrzeno = 1 where @id_platby = id;
			update prihlaska set poplatok_zaplateny = 1 where student_id_st=@idSt;
		end;
		else if(@uc like 'prihlaska' and @val < 400)--neuvazujme, ze by niekto poslal viac
		begin
			set @suma_platieb = (select sum(vyska_platby) from platby where ucel like 'prihlaska' group by ucel);
			if (@suma_platieb = 400)
			begin
				update platby set potvrzeno = 1 where @id_platby = id;
				update prihlaska set poplatok_zaplateny = 1 where student_id_st=@idSt;
			end;
		end;
		else if(@uc like 'ZS' and @val = 28000 and @datPrijatia <= convert(date, '15.11.' + convert(varchar(4), convert(int, year(convert(date, getdate())))), 104))
		begin
			update platby set potvrzeno = 1 where @id_platby = id;
			if((select top 1 dat_zac_stud from student where id_st = @idSt) is null)
			begin
				if((select hodnoceni from vysledky_prijmani where prihlaska_id_pr=(select id_pr from prihlaska where student_id_st = @idSt)) >= 50)
				begin
					update student set dat_zac_stud = convert(date, '01.10.' + convert(varchar(4), convert(int, year(convert(date, getdate())))), 104) where id_st=@idSt;
					update student set rocnik = 1 where id_st=@idSt;
				end;
			end;
			else
			begin
				update student set rocnik = rocnik + 1 where id_st=@idSt;
			end;
		end;
		else if((@uc like 'ZS') and (@val < 28000) and (@datPrijatia <= convert(date, '15.11.' + convert(varchar(4), convert(int, year(convert(date, getdate())))), 104)))
		begin
			set @suma_platieb = (select sum(vyska_platby) from platby where ucel like 'ZS' and student_id_st=@idSt group by ucel);
			--select sum(vyska_platby) as [platby doposial] from platby where ucel like 'ZS' group by ucel
			if(@suma_platieb = 28000)
			begin
				update platby set potvrzeno = 1 where @uc like 'ZS' and student_id_st=@idSt;
				if((select top 1 dat_zac_stud from student where id_st = @idSt) is null)
				begin
					if((select hodnoceni from vysledky_prijmani where prihlaska_id_pr=(select id_pr from prihlaska where student_id_st = @idSt)) >= 50)
					begin
						update student set dat_zac_stud = convert(date, '01.10.' + convert(varchar(4), convert(int, year(convert(date, getdate())))), 104) where id_st=@idSt;
						update student set rocnik = 1 where id_st=@idSt;
					end;
				end;
				else
				begin
					update student set rocnik = rocnik + 1 where id_st=@idSt;
				end;
			end;
		end;
		else if((@uc like 'LS') and (@val = 10000) and (@datPrijatia <= convert(date, '15.04.' + convert(varchar(4), convert(int, year(convert(date, getdate())))), 104)))
		begin
			update platby set potvrzeno = 1 where @uc like 'LS' and student_id_st=@idSt;
		end;
		else if((@uc like 'LS') and (@val < 10000) and (@datPrijatia <= convert(date, '15.04.' + convert(varchar(4), convert(int, year(convert(date, getdate())))), 104)))
		begin
			set @suma_platieb = (select sum(vyska_platby) from platby where ucel like 'LS' and student_id_st=@idSt group by ucel);
			--select sum(vyska_platby) as [platby zatial ls] from platby where ucel like 'LS' group by ucel
			if(@suma_platieb = 10000)
			begin
				update platby set potvrzeno = 1 where @uc like 'LS' and student_id_st=@idSt;
			end;
		end;
go
create trigger hodnotenie
	on vysledky_prijmani
	for update
	as
		declare @hodn as int;
		declare @id_st as int;
		declare @suma_platieb as int;
	
		set @hodn=(select hodnoceni from inserted);
		set @id_st=(select top 1 s.id_st from inserted as i
					join prihlaska as p on i.prihlaska_id_pr=p.id_pr 
					join student as s on p.student_id_st=s.id_st);
		set @suma_platieb = (select sum(vyska_platby) from platby where ucel like 'ZS' and student_id_st=@id_st group by ucel);
		if(@suma_platieb = 28000)
		begin
			if((select top 1 dat_zac_stud from student where id_st = @id_st) is null)
			begin
				if(@hodn >= 50)
				begin
					update student set dat_zac_stud = convert(date, '01.10.' + convert(varchar(4), convert(int, year(convert(date, getdate())))), 104) where id_st=@id_st;
					update student set rocnik = 1 where id_st=@id_st;
				end;
			end;
		end;
go
create trigger hodZP
on hodnotenie_ucitelov
for insert
as
	declare @znamka as int;
	declare @termin_kon as date;
	declare @idHodp as int;

	set @znamka = (select i.stupnice_id from inserted as i);
	set @idHodp = (select i.termin_hodnoceni_ZP_id_hodp from inserted as i);

	if(@znamka = 6) -- ak dostal F
	begin
		set @termin_kon = (select thzp.datum_konani from inserted as i, termin_hodnoceni_ZP as thzp
							where thzp.id_hodp = i.termin_hodnoceni_ZP_id_hodp);
		set @termin_kon = dateadd(year, 1,  @termin_kon)
		update termin_hodnoceni_ZP set datum_konani = @termin_kon where id_hodp = @idHodp;
	end;
					
----------------------------------------------------------------------------------------------
go
----------------------------------------------------------------------------------------------

go
--begin tran ukonci_stud
--	declare @chyba as varchar(255);
--	exec ukonci_studium 4, @errMsg=@chyba output;
--	if(not @chyba is null)
--	begin
--		select @chyba as Chyba0
--		rollback tran ukonci_stud;
--	end;
--	else
--	begin
--		select @chyba as Chyba0
--		rollback tran ukonci_stud;
--	end;
 -- nespustat
go
--0 init 
begin tran sprav_garantov
	update vyucujici set druh_vyuc_id=2 where 1=1
	select * from vyucujici;
commit tran sprav_garantov;
--rollback tran sprav_garantov
go
begin tran priradDoProgramu -- nahadzat ucitelov do programu
insert into vyucujici_v_programe(vyucujici_id_uc, st_program_id_sp)
	select id_uc, 1 from vyucujici;
	select * from vyucujici_v_programe
--delete from vyucujici_v_programe where 1=1
--dbcc checkident('vyucujici_v_programe', reseed, 0);
commit tran priradDoProgramu 
go
begin tran pridajDozor
	declare @chyba as varchar(255);
	exec zadelDozor 1, 2, 3, 4, 1, @errMsg = @chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chybaDozor;
		rollback tran pridajDozor;
	end;
	else
	begin
		select * from dozorcovia_programov;
		commit tran pridajDozor;
	end;
	--delete from dozorcovia_programov where 1=1;
	--dbcc checkident('dozorcovia_programov', reseed, 0);
go
-- 1
begin tran registracia -- registracia
	declare @chyba as varchar(255);
	exec regStudent 'Alojz', 'Voromej', 21, 45789012356, 1, 3, 'Slovensko', 'Ruzomberok', 'Hviezdoslavova 11', '851 62', @errorMsg = @chyba output;
	if (not @chyba is null)
	begin
		select @chyba;
		rollback tran registracia
	end;
	else
	begin
		save tran registracia1;
	end;
	exec regStudent 'Imre', 'Polonyi', 24, 19653317349, 1, 3, 'Slovensko', 'Ceklis', 'Bernolakova 2', '851 78', @errorMsg = @chyba output;
	if (not @chyba is null)
	begin
		select @chyba;
		rollback tran registracia1;
	end;
	else
	begin
		save tran registracia2;
	end;
	exec regStudent 'Patrik', 'Kirtap', 21, 11122233344, 1, 3, 'Slovensko', 'Bratislava', 'Jaskov Rad', '841 05', @errorMsg = @chyba output;
	if (not @chyba is null)
	begin
		select @chyba;
		rollback tran registracia2;
	end;
	else
	begin
		commit tran registracia;
	end;
	select * from student;
	select * from adresa;
	
	--reset
	--delete from adresa where 1=1;
	--delete from student where 1=1;
	--dbcc checkident ('student', reseed, 0)
	--dbcc checkident ('adresa', reseed, 0) -- registracia
go -- vypisanie terminu
begin tran vypis_termin_prijz -- datum a cas by sa mal zadavat europskym sposobom t.j. 104
	declare @chybaVypis as varchar (255);
	declare @chybaRef as varchar(255);
	exec vypisPrijZ '30.03.2017', 'Fakulta podnikatelska VUT Brno aula p381'
	, '02:00:00', '09:15:00', 1, @errMsg=@chybaVypis output;
	if(@chybaVypis is null)
	begin
		commit tran vypis_termin_prijz;
	end;
	else
	begin 
		select @chybaVypis as ['chyba pri zadavani terminu'];
		rollback tran vypis_termin_prijz;
	end;
select * from prijmaci_riz;
select * from referentka_prijZ;
	--reset
	--delete from prijmaci_riz where 1=1;
	--dbcc checkident ('prijmaci_riz', reseed, 0);
go
begin tran podanie_prihlasky -- prihlaska
	declare @chybap as varchar(255);
	select * from zobrazTerminyPrijimaciekAReferentky;
	exec podatPrihlasku 1, 1, 1, @errMsg = @chybap output;
	if(not @chybap is null)
	begin
		select 'Chyba pri podavani prihlasky 0' + @chybap;
		rollback tran podanie_prihlasky;
	end;
	else
	begin
		save tran podanie_prihlasky1;
	end;
	exec podatPrihlasku 2, 1, 1, @errMsg = @chybap output;
	if(not @chybap is null)
	begin
		select 'Chyba pri podavani prihlasky 1' + @chybap;
		rollback tran podanie_prihlasky1;
	end;
	else
	begin
		save tran podanie_prihlasky2;
	end;
	exec podatPrihlasku 3, 1, 1, @errMsg = @chybap output;
	if(not @chybap is null)
	begin
		select 'Chyba pri podavani prihlasky 2' + @chybap;
		rollback tran podanie_prihlasky2;
	end;
	else
	begin
		commit tran podanie_prihlasky;
	end;
	select * from prihlaska;
	select * from vysledky_prijmani;
	--reset
	--delete from prihlaska where 1=1;
	--delete from vysledky_prijmani where 1=1;
	--dbcc checkident ('prihlaska', reseed, 0);
	--dbcc checkident ('vysledky_prijmani', reseed, 0);
go -- platba po castiach
begin tran zaplat_casti -- od prihlasky po platbu
	declare @chybaPlatba1 as varchar(255);

	exec vykonajPlatbu 'prihlaska', 400, 1, '02.02.2017', 1, @errMsg=@chybaPlatba1 output;
	if(not @chybaPlatba1 is null)
	begin
		select @chybaPlatba1 + ' chyba zaplat 0'; 
		rollback tran zaplat_casti;
	end
	else
	begin
		save tran zaplat_casti1;
	end;
	--priklad platby po castiach
	exec vykonajPlatbu 'LS', 5000, 1, '01.01.2017', 1, @errMsg=@chybaPlatba1 output;
	if(not @chybaPlatba1 is null)
	begin
		select @chybaPlatba1 + ' cyba zaplat 1';
		rollback tran zaplat_casti1;
	end
	else
	begin
		commit tran zaplat_casti
	end;
	select * from platby;
	select * from student;
	-- purge
	--delete from platby where 1=1;
	--dbcc checkident ('platby', reseed, 0);
	--mozno treba purge na student, adresa, prihlasky aj termin konania
	--delete from prihlaska where 1=1;
	--delete from vysledky_prijmani where 1=1;
	--dbcc checkident ('prihlaska', reseed, 0);
	--dbcc checkident ('vysledky_prijmani', reseed, 0);
	-- -- delete from adresa where 1=1
	-- -- delete from student where 1=1
	-- -- dbcc checkident ('adresa', reseed, 0);
	-- -- dbcc checkident ('student', reseed, 0);

go
begin tran zaplat_naraz --zaplatit naraz
--;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;--
	--platba naraz
	declare @chybaPlatbaN as varchar(255);
	exec vykonajPlatbu 'LS', 10000, 2, '01.01.2017', 1, @errMsg=@chybaPlatbaN output;
	if(not @chybaPlatbaN is null)
	begin
		select @chybaPlatbaN
		rollback tran zaplat_naraz;
	end;
	else 
	begin
		save tran zaplat_naraz1;
	end;
	exec vykonajPlatbu 'LS', 10000, 3, '04.01.2017', 1,  @errMsg=@chybaPlatbaN output;
	if(not @chybaPlatbaN is null)
	begin
		select @chybaPlatbaN
		rollback tran zaplat_naraz1;
	end
	else
	begin
		save tran zaplat_naraz2;
	end;
	exec platby_studenta 3, @errMsg=@chybaPlatbaN output;
	if(not @chybaPlatbaN is null)
	begin
		select @chybaPlatbaN
		rollback tran zaplat_naraz2;
	end
	else
	begin
		commit tran zaplat_naraz;
	end;
	select * from platby;
	
--;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;--
go
begin tran platba_casti2 -- jednorazova platba student na cast
	declare @chybaPlatba1 as varchar(255);
	exec vykonajPlatbu 'LS', 5000, 1, '02.04.2017', 1, @errMsg=@chybaPlatba1 output;
	if(not @chybaPlatba1 is null)
	begin
		select @chybaPlatba1
		rollback tran platba_casti2
	end;
	else
	begin
		select * from platby;
		select * from student;
		--rollback tran platba
		commit tran platba_casti2;
	end;
	--purge
	--delete from platby where 1=1;
	--dbcc checkident ('platby', reseed, 0);
go -- hodnotenie
begin tran zapisHodnotenie
	declare @chybaHodn as varchar(255);
	select * from zobraz_info_o_prihlaskach

	exec hodnoteniePrijmaciek 95, 1, @errMsg=@chybaHodn;
	if (not @chybaHodn is null) 
	begin
		select @chybaHodn + ' chyba hodnotenie';
		rollback tran zapisHodnotenie
	end;
	else
	begin
		save tran zapisHodnotenie1;
	end;
	exec hodnoteniePrijmaciek 62, 2, @errMsg=@chybaHodn;
	if (not @chybaHodn is null) 
	begin
		select @chybaHodn + ' chyba hodnotenie 1';
		rollback tran zapisHodnotenie1;
	end;
	else
	begin
		save tran zapisHodnotenie2;
	end;
	exec hodnoteniePrijmaciek 32, 3, @errMsg=@chybaHodn;
	if (not @chybaHodn is null) 
	begin
		select @chybaHodn + ' chyba hodnotenie 2';
		rollback tran zapisHodnotenie2;
	end;
	else
	begin
		commit tran zapisHodnotenie;
	end;
	select * from vysledky_prijmani
	select * from student;
	-- purge
	--delete from vysledky_prijmani where 1=1
	--delete from prihlaska where 1=1
go -- hypoteza 1
begin tran force_rocnik -- spusta sa ak platby zodpovedaju LS, aby bol nasilu zmeneny rocnik
	update student set rocnik=1 where id_st=1;
	update student set rocnik=1 where id_st=2;
	update student set rocnik=2 where id_st=3;
	select * from student;
	-- v pripade zlyhania purge
	--delete from platby where 1=1;
	--dbcc checkident ('platby', reseed, 0);
	
	--delete from prihlaska where 1=1;
	--delete from vysledky_prijmani where 1=1;
	--dbcc checkident ('prihlaska', reseed, 0);
	--dbcc checkident ('vysledky_prijmani', reseed, 0);

	-- -- delete from adresa where 1=1
	-- -- delete from student where 1=1
	-- -- dbcc checkident ('adresa', reseed, 0);
	-- -- dbcc checkident ('student', reseed, 0);
commit tran force_rocnik
go
begin tran ucitel -- tyka sa predmetov a kariet predmetov
	declare @chybaUc as varchar(255)
	exec zobrazGarantovePredmety 1, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel;
	end;
	else
	begin
		save tran ucitel1;
	end;
	exec pridatKartuPredmetu 'CZ', 'SapC', 1, 'ZS', 10, 'z,zk', 'CZ', 1, 1, 'Predmet je ukonceny zapoctom skuskou pouziva ECTS atd.', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SapC', 1, 'WS', 10, 'z,zk', 'CZ', 1, 1, 'To successfully pass this subject the students have to attend a test and a final exam. ECTS grading is used in this subject.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel1;
	end;
	else
	begin
		save tran ucitel2;
	end;
	exec pridatKartuPredmetu 'CZ', 'SubeC', 1, 'ZS', 5, 'z,zk', 'CZ', 1, 2, 'Predmet je ukonceny zapoctom skuskou a projekt.', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SubeC', 1, 'WS', 5, 'z,zk', 'CZ', 1, 2, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel2;
	end;
	else
	begin
		save tran ucitel3;
	end;
	exec pridatKartuPredmetu 'CZ', 'SmC', 1, 'ZS', 5, 'z,zk', 'CZ', 1, 3, 'Predmet je ukonceny zapoctom skuskou a projektom.', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SmC', 1, 'WS', 5, 'z,zk', 'CZ', 1, 3, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel3;
	end;
	else
	begin
		save tran ucitel4;
	end;
	exec pridatKartuPredmetu 'CZ', 'SpmC', 1, 'ZS', 5, 'z,zk', 'CZ', 1, 4, 'Predmet je ukonceny zapoctom skuskou a projekt.', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SpmC', 1, 'WS', 5, 'z,zk', 'CZ', 1, 4, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel4;
	end;
	else
	begin
		save tran ucitel5;
	end;
	exec pridatKartuPredmetu 'CZ', 'SqmC', 1, 'ZS', 5, 'z,zk', 'CZ', 1, 5, 'Predmet je ukonceny zapoctom skuskou a projekt.', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SqmC', 1, 'WS', 5, 'z,zk', 'CZ', 1, 5, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel5;
	end;
	else
	begin
		save tran ucitel6;
	end;
	exec pridatKartuPredmetu 'CZ', 'Sel1C', 1, 'ZS', 0, 'z', 'EN', 1, 6, 'Predmet je ukonceny zapoctom', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'Sel1C', 1, 'WS', 0, 'z', 'EN', 1, 6, 'To successfully pass this subject the students have to attend a test'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel6;
	end;
	else
	begin
		save tran ucitel7;
	end;
	exec pridatKartuPredmetu 'CZ', 'SsmC', 1, 'LS', 5, 'z,zk', 'CZ', 1, 7, 'Predmet je ukonceny zapoctom skuskou.', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SsmC', 1, 'SS', 5, 'z,zk', 'CZ', 1, 7, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel7;
	end;
	else
	begin
		save tran ucitel8;
	end;
	exec pridatKartuPredmetu 'CZ', 'SemC', 1, 'LS', 5, 'z,zk', 'CZ', 1, 8, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SemC', 1, 'SS', 5, 'z,zk', 'CZ', 1, 8, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel8;
	end;
	else
	begin
		save tran ucitel9;
	end;
	exec pridatKartuPredmetu 'CZ', 'SbiC', 1, 'LS', 10, 'z,zk', 'CZ', 1, 9, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SbiC', 1, 'SS', 10, 'z,zk', 'CZ', 1, 9, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel9;
	end;
	else
	begin
		save tran ucitel10;
	end;
	exec pridatKartuPredmetu 'CZ', 'SorC', 1, 'LS', 5, 'z,zk', 'CZ', 1, 10, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SorC', 1, 'SS', 5, 'z,zk', 'CZ', 1, 10, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel10;
	end;
	else
	begin
		save tran ucitel11;
	end;
	exec pridatKartuPredmetu 'CZ', 'SsaC', 1, 'LS', 5, 'z,zk', 'CZ', 1, 11, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SsaC', 1, 'SS', 5, 'z,zk', 'CZ', 1, 11, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel11;
	end;
	else
	begin
		save tran ucitel12;
	end;
	exec pridatKartuPredmetu 'CZ', 'Sel2C', 1, 'LS', 10, 'z,zk', 'EN', 1, 12, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'Sel2C', 1, 'SS', 10, 'z,zk', 'EN', 1, 12, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel12;
	end;
	else
	begin
		save tran ucitel13;
	end;
	exec pridatKartuPredmetu 'CZ', 'SisC', 2, 'ZS', 5, 'z,zk', 'CZ', 1, 13, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SisC', 2, 'WS', 5, 'z,zk', 'CZ', 1, 13, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel13;
	end;
	else
	begin
		save tran ucitel14;
	end;
	exec pridatKartuPredmetu 'CZ', 'SictmC', 2, 'ZS', 5, 'z,zk', 'CZ', 1, 14, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SictmC', 2, 'WS', 5, 'z,zk', 'CZ', 1, 14, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel14;
	end;
	else
	begin
		save tran ucitel15;
	end;
	exec pridatKartuPredmetu 'CZ', 'SfaC', 2, 'ZS', 5, 'z,zk', 'CZ', 1, 15, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SfaC', 2, 'WS', 5, 'z,zk', 'CZ', 1, 15, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel15;
	end;
	else
	begin
		save tran ucitel16;
	end;
	exec pridatKartuPredmetu 'CZ', 'SmaC', 2, 'ZS', 5, 'z,zk', 'CZ', 1, 16, 'Predmet je ukonceny zapoctom skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SmaC', 2, 'WS', 5, 'z,zk', 'CZ', 1, 16, 'To successfully pass this subject the students have to attend a test and a final exam and present project.'
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel16;
	end;
	else
	begin
		save tran ucitel17;
	end;
	exec pridatKartuPredmetu 'CZ', 'ScpC', 2, 'ZS', 20, 'kz', 'CZ', 1, 9, 'Predmet je ukonceny skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'ScpC', 2, 'WS', 20, 'kz', 'CZ', 1, 9, 'To successfully pass this subject the students have to attend a final exam '
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel17;
	end;
	else
	begin
		save tran ucitel18;
	end;
	exec pridatKartuPredmetu 'CZ', 'SrmC', 2, 'LS', 10, 'z, zk', 'CZ', 1, 10, 'Predmet je ukonceny skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SrmC', 2, 'SS', 10, 'z, zk', 'CZ', 1, 10, 'To successfully pass this subject the students have to attend a final exam '
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel18;
	end;
	else
	begin
		save tran ucitel19;
	end;
	exec pridatKartuPredmetu 'CZ', 'SstmC', 2, 'LS', 10, 'z, zk', 'CZ', 1, 18, 'Predmet je ukonceny skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SstmC', 2, 'SS', 10, 'z, zk', 'CZ', 1, 18, 'To successfully pass this subject the students have to attend a final exam '
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel19;
	end;
	else
	begin
		save tran ucitel20;
	end;
	exec pridatKartuPredmetu 'CZ', 'SciC', 2, 'LS', 10, 'z, zk', 'CZ', 1, 19, 'Predmet je ukonceny skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SciC', 2, 'SS', 10, 'z, zk', 'CZ', 1, 19, 'To successfully pass this subject the students have to attend a final exam '
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel20;
	end;
	else
	begin
		save tran ucitel21;
	end;
	exec pridatKartuPredmetu 'CZ', 'SdC', 2, 'LS', 40, 'z, zk', 'CZ', 1, 9, 'Predmet je ukonceny skuskou', @errMsg=@chybaUc output;
	exec pridatKartuPredmetu 'EN', 'SdC', 2, 'SS', 40, 'z, zk', 'CZ', 1, 9, 'To successfully pass this subject the students have to attend a final exam '
	, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel21;
	end;
	else
	begin
		save tran ucitel22;
	end;
	exec zobrazKartyMojichPredmetov 9, @errMsg=@chybaUc output;
	if(not @chybaUc is null)
	begin
		select @chybaUc;
		rollback tran ucitel;
	end;
	else
	begin
		commit tran ucitel
	end;
	select * from karta_predmetu;
	--purge
	--delete from karta_predmetu where 1=1;
go -- ZP
begin tran administrativa_ucitel --vypisat pracu
	declare @chybaAdm as varchar(255);
	exec vypis_temu_prace 1, 'Jak Programovat', @errMsg=@chybaAdm output;
	if(not @chybaAdm is null)
	begin
		select @chybaAdm;
		rollback tran administrativa_ucitel;
	end;
	else
	begin
		save tran administativa_ucitel1;
	end;
	exec vypis_temu_prace 2, 'Ekonomie Německa', @errMsg=@chybaAdm output;
	if(not @chybaAdm is null)
	begin
		select @chybaAdm;
		rollback tran administrativa_ucitel1;
	end;
	else
	begin
		save tran administrativa_ucitel2;
	end;
	exec vypisTerminHodnZP 1, '21.05.2018', @errMsg=@chybaAdm output;
	if(not @chybaAdm is null)
	begin
		select @chybaAdm;
		rollback tran administrativa_ucitel2;
	end;
	else
	begin
		commit tran administrativa_ucitel
	end;
	select * from tema;
	select * from termin_hodnoceni_ZP;

	--purge
	--delete from tema where 1=1;
	--delete from termin_hodnoceni_ZP where 1=1;
	--dbcc checkident('tema', reseed, 0);
	--dbcc checkident('termin_hodnoceni_ZP', reseed, 0);
go -- zp 1
begin tran zavPraca
	declare @chybaZP as varchar(255);

	exec vyberPracu 3, 1, 'vypracovat na temu... pod dohladom...' ,null, '25.11.2017', @errMsg=@chybaZP output;
	if(not @chybaZP is null)
	begin
		select @chybaZP;
		rollback tran zavPraca;
	end;
	else
	begin
		save tran zavPraca1;
	end;
	exec zobrazZpStudenta 3, @errMsg=@chybaZP output;
	if(not @chybaZP is null)
	begin
		select @chybaZP;
		rollback tran zavPraca1;
	end;
	else
	begin
		select * from zaverecna_prace;
		commit tran zavPraca;
	end;
	select * from zobraz_temy_prac;
	select * from zobraz_terminy

	--purge
	--delete from zaverecna_prace where 1=1;
	--dbcc checkident ('zaverecna_prace', reseed, 0);

go -- zp 2
begin tran terminZP
	declare @chybaZPTerm as varchar(255);
	declare @idPr as int;
	exec zobrazZpStudenta 3, @errMsg=@chybaZPTerm output;
	if(not @chybaZPTerm is null)
	begin
		select @chybaZPTerm;
		rollback tran terminZP;
	end;
	else
	begin
		save tran terminZP1;
	end;
	exec getIdPraceStudenta 3, @idPr = @idPr output, @errMsg = @chybaZPTerm output;
	if(not @chybaZPTerm is null)
	begin
		select @chybaZPTerm;
		rollback tran terminZP1;
	end;
	else
	begin
		save tran zavPraca2;
		exec vyberTermin 3, @idPr, 1, @errMsg=@chybaZPTerm output;
		if(not @chybaZPTerm is null)
		begin
			select @chybaZPTerm;
			rollback tran terminZP2;
		end;
		else
		begin
			save tran terminZP3;
		end;
	end;
	exec detailZPStudenta 3, @errMsg = @chybaZPTerm output;
	if(not @chybaZPTerm is null)
	begin
		select @chybaZPTerm;
		rollback tran terminZP3;
	end;
	else
	begin
		select * from prace_v_termine;
		commit tran terminZP;
	end;
	--purge
	--delete from prace_v_termine where 1=1;
	--dbcc checkident ('prace_v_termine', reseed, 0);
go -- zp 3
begin tran hodnotenieZp
	declare @chybaHodn  as varchar(255);
	declare @idHodp as int;
	
	exec getHodpOfZP 3, @idHodp = @idHodp output, @errMsg = @chybaHodn output;
	if(not @chybaHodn is null)
	begin
		select @chybaHodn + ' chyba hodn 0';
		rollback tran hodnotenieZP;
	end;
	else
	begin
		save tran hodnotenieZP1;
	end;
	exec zadaj_hodnotenie_zp 1, 6, @idHodp, @errMsg=@chybaHodn output;
	if(not @chybaHodn is null)
	begin
			select @chybaHodn + ' chyba Hodn 1';
			rollback tran hodnotenieZp1;
		end;
		else
		begin
			save tran hodnotenieZp2;
			exec zobraz_studentove_hodnotenie 3, @errMsg=@chybaHodn output;
			if(not @chybaHodn is null)
			begin
				select @chybaHodn + ' chyba hodn zp 2';
				rollback tran hodnotenieZp2;
			end;
			else
			begin
				select * from hodnotenie_ucitelov;
				select * from zobraz_terminy;
				rollback tran hodnotenieZp;
				--commit tran hodnotenieZp;
			end;
		end;
		-- purge
		--delete from hodnotenie_ucitelov where 1=1;
		--dbcc checkident('hodnotenie_ucitelov', reseed, 0);
go -- zapocty
begin tran ucitelia -- vypisovanie terminov zapoctov, pridelovanie predmetov na ucenie rocnikovym ucitelom
	declare @chybaUct as varchar(255);
	--exec zobrazGarantovePredmety 1, @errMsg=@chybaUct output;
	exec zobrazUcitelovePredmety 9, @errMsg=@chybaUct output;
	if(not @chybaUct is null)
	begin
		select @chybaUct as ChybaUCT0;
		rollback tran ucitelia;
	end;
	else
	begin
		save tran ucitelia1;
	end;
	exec pridajUcenyPredmet 1, 'SapC', @errMsg = @chybaUct output;
	if(not @chybaUct is null)
	begin
		select @chybaUct as ChybaUCT1;
		rollback tran ucitelia1;
	end;
	else
	begin
		save tran ucitelia2;
	end;
	exec pridajUcenyPredmet 1, 'SpmC', @errMsg = @chybaUct output;
	if(not @chybaUct is null)
	begin
		select @chybaUct as ChybaUCT2;
		rollback tran ucitelia2;
	end;
	else
	begin
		save tran ucitelia3;
	end;
	exec zobrazPredmRU 1, @errMsg=@chybaUct output;
	if(not @chybaUct is null)
	begin
		select @chybaUct as ChybaUCT3;
		rollback tran ucitelia3;
	end;
	else
	begin
		save tran ucitelia4;
	end;
	exec vypisTerminZapoctu 1, '05.12.2017', 'ucebna 256', 'SapC', @errMsg=@chybaUct output;
	if(not @chybaUct is null)
	begin
		select @chybaUct as ChybaUCT4;
		rollback tran ucitelia4;
	end;
	else
	begin
		save tran ucitelia5;
	end;
	exec vypisTerminZapoctu 4, '18.12.2017', 'ucebna UC.80 FEKT', 'SpmC', @errMsg=@chybaUct output;
	if(not @chybaUct is null)
	begin
		select @chybaUct as ChybaUCT5;
		rollback tran ucitelia5;
	end;
	else
	begin
		save tran ucitelia6;
	end;
	exec vypisTerminZapoctu 1, '06.12.2017', 'ucebna 256', 'SapC', @errMsg=@chybaUct output;
	if(not @chybaUct is null)
	begin
		select @chybaUct as ChybaUCT6;
		rollback tran ucitelia6;
	end;
	else
	begin
		select * from zapocet;
		select * from predmety_na_zapoctoch;
		select * from ucene_predmety
		commit tran ucitelia;
	end;
	--purge
	--delete from predmety_na_zapoctoch where 1=1;
	--delete from zapocet where 1=1;
	--delete from ucene_predmety where 1=1;
	--dbcc checkident ('zapocet', reseed, 0);
	--dbcc checkident ('predmety_na_zapoctoch', reseed, 0);
	--dbcc checkident ('ucene_predmety', reseed, 0);
go -- zapocty 1 
begin tran delegujPravomociZapocty -- pravomoci sa moze delegovat na hocikoho bez ohladu ci dany predmet uci, alebo nie
	select * from rocnikovy_ucitel;
	exec delegace_prav_zap_roc_uc 1, 1, 1;
	exec delegace_prav_zap_roc_uc 4, 2, 2;
	select * from pravo_zapoc;
	--purge it
	-- delete from pravo_zapoc where 1=1;
	-- dbcc checkident ('pravo_zapoc', reseed, 0);
	commit tran delegujPravomociZapocty;
--rollback tran delegujPravomociZapocty;
go -- medium tst nech pred zapocty 2
begin tran reg1
declare @chyba as varchar(255);

--delete from prihlaska where id_pr=4;
--dbcc checkident('prihlaska', reseed, 3);
--delete from adresa where student_id_st = 4
--dbcc checkident ('adresa', reseed, 3);
--delete from student where id_st=4;
--dbcc checkident('student', reseed, 3);
--delete from vysledky_prijmani where id=4;
--dbcc checkident('vysledky_prijmani', reseed, 3);
--delete from platby where student_id_st=4;
--dbcc checkident('platby', reseed, 5);
--delete from vysledky_prijmani where id=4;
--dbcc checkident('vysledky_prijmani', reseed, 3);
--delete from predmet_student where student_id_st=4;
--dbcc checkident('predmet_student', reseed, 0);

exec regStudent 'Jakub', 'Malostransky', 19, 19653317349, 1, 3, 'Slovensko', 'Nove Zamky', 'Cervena 6', '851 81', @errorMsg = @chyba output;
	if (not @chyba is null)
	begin
		select @chyba;
		rollback tran reg1;
	end;
	else
	begin
		save tran reg11;
	end;
	select * from student
	exec podatPrihlasku 4, 1, 1, @errMsg = @chyba output;
	if(not @chyba is null)
	begin
		select 'Chyba pri podavani prihlasky 2' + @chyba;
		rollback tran reg11;
	end;
	else
	begin
		save tran reg12;
	end;
	select * from prihlaska;
	select * from vysledky_prijmani;
	exec vykonajPlatbu 'prihlaska', 400, 4, '02.02.2017', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba + ' chyba zaplat 0'; 
		rollback tran reg12;
	end
	else
	begin
		save tran reg13;
	end;
	select * from platby
	exec vykonajPlatbu 'ZS', 28000, 4, '01.01.2017', 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba
		rollback tran reg13;
	end;
	else 
	begin
		save tran reg14;
	end;
	select * from platby;
	exec hodnoteniePrijmaciek 99, 4, @errMsg=@chyba;
	if (not @chyba is null) 
	begin
		select @chyba + ' chyba hodnotenie';
		rollback tran reg14
	end;
	else
	begin
		select * from vysledky_prijmani;
		select * from student;
		save tran reg15
	end;
	--exec registrujPovinnePredmety 4, '12.02.2017', 1, @errMsg = @chyba output;
	exec registrujPovinnePredmety 4, '12.09.2017', 1, @errMsg = @chyba output;
	if(not @chyba is null)
	begin
		select @chyba + ' chyba registruj pov ';
		rollback tran reg15;
	end;
	else
	begin
		select * from predmet_student;
		commit tran reg1;
		--save tran reg16;
	end;
	--povinne volitelne ani iny typ neexistuje v scenari
go -- zapocty 2
begin tran zapocty
	declare @chybaZap as varchar(255);
	select * from zobraz_predmety_a_zapocty;
	exec registrujNaZapocet 4, 1, @errMsg=@chybaZap output;
	if(not @chybaZap is null)
	begin
		select @chybaZap as chybaZap0;
		rollback tran zapocty;
	end;
	else
	begin
		save tran zapocty1;
	end;	
	exec zapoctyStudenta 4, @errMsg=@chybaZap output;
	if(not @chybaZap is null)
	begin
		select @chybaZap as chybaZap1;
		rollback tran zapocty1;
	end;
	else
	begin
		save tran zapocty2;
	end
	select * from stud_zap;
	exec ohodnotZapV 1, 1, 4, 6, @errMsg=@chybaZap output;
	if (not @chybaZap is null)
	begin
		select @chybaZap + ' chyba hodnotenie';
		rollback tran zapocty2;
	end;
	else
	begin
		save tran zapocty3;
	end
	select * from hodnotenie_zap;
	exec vysledkyZap 4, 1, @errMsg=@chybaZap output;
	if(not @chybaZap is null)
	begin
		select @chybaZap + ' chyba vypis vysledkov';
		rollback tran zapocty3;
	end;
	else
	begin
		save tran zapocty4;
	end;
	exec registrujNaZapocet 4, 3, @errMsg=@chybaZap output;
	if(not @chybaZap is null)
	begin
		select @chybaZap as chybaZap3;
		rollback tran zapocty4;
	end;
	else
	begin
		save tran zapocty5;
	end;	
	exec zapoctyStudenta 4, @errMsg=@chybaZap output;
	if(not @chybaZap is null)
	begin
		select @chybaZap as chybaZap5;
		rollback tran zapocty5;
	end;
	else
	begin
		save tran zapocty6;
	end
	exec ohodnotZapRU 1, 3, 4, 2, @errMsg=@chybaZap output;
	if (not @chybaZap is null)
	begin
		select @chybaZap + ' chyba hodnotenie';
		rollback tran zapocty6;
	end;
	else
	begin
		save tran zapocty7;
	end
	exec vysledkyZap 4, 3, @errMsg=@chybaZap output;
	if(not @chybaZap is null)
	begin
		select @chybaZap + ' chyba vypis vysledkov';
		rollback tran zapocty8;
	end;
	else
	begin
		select * from zapocet;
		select * from stud_zap;
		select * from hodnotenie_zap;
		commit tran zapocty;
	end;
	--purge
	--delete from stud_zap where 1=1;
	--dbcc checkident('stud_zap', reseed, 0);
	--delete from hodnotenie_zap where 1=1;
	--dbcc checkident('hodnotenie_zap', reseed, 0);

go -- skusky
begin tran skusky
	declare @chyba as varchar(255);
	exec vypisTerminSkusky 1, '16.02.2018', 'miesto', 'SapC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as vypis0;
		rollback tran skusky;
	end;
	else
	begin
		save tran skusky1;
	end;
	exec vypisTerminSkusky 1, '19.02.2018', 'miesto2', 'SapC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as vypis1;
		rollback tran skusky1;
	end;
	else
	begin
		save tran skusky2;
	end;
	exec vypisTerminSkusky 4, '21.02.2018', 'miesto', 'SpmC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as vypis2;
		rollback tran skusky2;
	end;
	else
	begin
		select * from zobraz_predmety_a_skusky;
		commit tran skusky
	end;
	--purge
	--delete from predmety_na_skuskach where 1=1;
	--delete from zkouska where 1=1;
	--dbcc checkident('predmety_na_skuskach', reseed, 0);
	--dbcc checkident('zkouska', reseed, 0);

go -- skusky 1
begin tran delegujPravomociSkusky
select * from zkouska;
	select * from rocnikovy_ucitel;
	exec delegace_prav_zk_roc_uc 1, 1, 1;
	exec delegace_prav_zk_roc_uc 4, 3, 3;
	select * from pravo_zk;
	--purge it
	-- delete from pravo_zk where 1=1;
	-- dbcc checkident ('pravo_zk', reseed, 0);
	commit tran delegujPravomociSkusky;
--rollback tran delegujPravomociSkusky
go
begin tran skusky2 -- zabsolvovanie skusky
	declare @chyba as varchar(255);
	select * from zobraz_predmety_a_skusky;
	exec registrujNaSkusku 4, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba0;
		rollback tran skusky2;
	end;
	else
	begin
		save tran skusky21;
	end;	
	exec skuskyStudenta 4, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba1;
		rollback tran skusky21;
	end;
	else
	begin
		select * from stud_zk;
		save tran skusky22;
	end;
	exec ohodnotZkV 1, 1, 4, 6, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba2;
		rollback tran skusky22;
	end;
	else
	begin
		save tran skusky23;
	end;
	exec vysledkyZk 4, 1, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba3;
		rollback tran skusky23;
	end;
	else
	begin
		save tran skusky24;
	end;
	exec registrujNaSkusku 4, 2, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba4;
		rollback tran skusky24;
	end;
	else
	begin
		save tran skusky25;
	end;	
	exec skuskyStudenta 4, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba5;
		rollback tran skusky25;
	end;
	else
	begin
		select * from stud_zk;
		save tran skusky26;
	end;
	exec ohodnotZkRu 1, 2, 4, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba6;
		rollback tran skusky26;
	end;
	else
	begin
		save tran skusky27;
	end;
	exec vysledkyZk 4, 2, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba7;
		rollback tran skusky27;
	end;
	else
	begin
		select * from zkouska;
		select * from hodn_zk;
		select * from stud_zk;
		commit tran skusky2;
	end;
	--purge
	--delete from stud_zk where 1=1;
	--dbcc checkident('stud_zk', reseed, 0);
	--delete from hodn_zk where 1=1;
	--dbcc checkident('hodn_zk', reseed, 0);
go

-- velky test, nech posledny
-- rocnik 1. ZS.
-- nech 1. rocnik = 2017
-- nech 2. rocnik = 2018
begin tran vtReg
declare @chyba as varchar(255);
declare @lastId as int;
declare k cursor scroll for select id_st from student;
	
exec regStudent 'Vladimira', 'Cernakova', 22, 15846212389, 0, 3, 'Slovensko', 'Kosice', 'Tankistov 12', '878 91', @errorMsg = @chyba output;
	if (not @chyba is null)
	begin
		select @chyba as chyba0;
		rollback tran vtReg;
	end;
	else
	begin
		save tran vtReg1;
	end;
	select * from student
	open k;
	fetch last from k into @lastId;
	close k;
	deallocate k;
	exec podatPrihlasku @lastId, 1, 1, @errMsg = @chyba output;
	if(not @chyba is null)
	begin
		select 'Chyba pri podavani prihlasky 1' + @chyba;
		rollback tran vtReg1;
	end;
	else
	begin
		save tran vtReg2;
	end;
	select * from prihlaska;
	select * from vysledky_prijmani;
	exec vykonajPlatbu 'prihlaska', 400, @lastId, '08.02.2017', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba2; 
		rollback tran vtReg2;
	end
	else
	begin
		save tran vtReg3;
	end;
	select * from platby
	exec vykonajPlatbu 'ZS', 28000, @lastId, '10.01.2017', 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba3
		rollback tran vtReg3;
	end;
	else 
	begin
		save tran vtReg4;
	end;
	select * from platby;
	exec hodnoteniePrijmaciek 99, @lastId, @errMsg=@chyba;
	if (not @chyba is null) 
	begin
		select @chyba as chyba4;
		rollback tran vtReg4;
	end;
	else
	begin
		select * from vysledky_prijmani;
		select * from student;
		save tran vtReg5;
	end;
	--exec registrujPovinnePredmety 4, '12.02.2017', 1, @errMsg = @chyba output;
	exec registrujPovinnePredmety @lastId, '12.09.2017', 1, @errMsg = @chyba output; --override
	if(not @chyba is null)
	begin
		select @chyba as chyba5;
		rollback tran vtReg5;
	end;
	else
	begin
		select * from predmet_student;
		save tran vtReg6;
		--save tran reg16;
	end;
	
--dbcc checkident('prihlaska', reseed, 4);
--dbcc checkident ('adresa', reseed, 4);
--dbcc checkident('student', reseed, 4);
--dbcc checkident('platby', reseed, 7);
--dbcc checkident('vysledky_prijmani', reseed, 4);
--dbcc checkident('predmet_student', reseed, 6);

	select * from predmet order by vyucujici_id_uc
	exec vypisTerminZapoctu 2, '09.12.2017', 'ucebna 381', 'SubeC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as Chyba6;
		rollback tran vtReg6;
	end;
	else
	begin
		select * from zapocet;
		save tran vtReg7;
	end;
	exec vypisTerminZapoctu 3, '10.12.2017', 'ucebna 225', 'SmC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as Chyba7;
		rollback tran vtReg7;
	end;
	else
	begin
		select * from zapocet;
		save tran vtReg8;
	end;
	exec vypisTerminZapoctu 5, '18.12.2017', 'ucebna 225', 'SqmC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as Chyba8;
		rollback tran vtReg8;
	end;
	else
	begin
		select * from zapocet;
		save tran vtReg9;
	end;
	exec vypisTerminZapoctu 6, '15.12.2017', 'ucebna 215', 'Sel1C', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as Chyba9;
		rollback tran vtReg9;
	end;
	else
	begin
		select * from zapocet;
		save tran vtReg10;
	end;
	--purge
	--delete from zapocet where id_zap >3;
	--dbcc checkident('zapocet', reseed, 3);

	select * from zobraz_predmety_a_zapocty;
	exec registrujNaZapocet @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba10;
		rollback tran vtReg10;
	end;
	else
	begin
		save tran vtReg11;
	end;	
	exec registrujNaZapocet @lastId, 2, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba11;
		rollback tran vtReg11;
	end;
	else
	begin
		save tran vtReg12;
	end;	
	exec registrujNaZapocet @lastId, 4, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba12;
		rollback tran vtReg12;
	end;
	else
	begin
		save tran vtReg13;
	end;
	exec registrujNaZapocet @lastId, 5, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba13;
		rollback tran vtReg13;
	end;
	else
	begin
		save tran vtReg14;
	end;	
	exec registrujNaZapocet @lastId, 6, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba14;
		rollback tran vtReg14;
	end;
	else
	begin
		save tran vtReg15;
	end;	
	exec registrujNaZapocet @lastId, 7, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba15;
		rollback tran vtReg15;
	end;
	else
	begin
		save tran vtReg16;
	end;
	select * from stud_zap;
	exec zapoctyStudenta @lastId, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba16;
		rollback tran vtReg16;
	end;
	else
	begin
		save tran vtReg17;
	end
	exec ohodnotZapV 1, 1, @lastId, 1, @errMsg=@chyba output;
	if (not @chyba is null)
	begin
		select @chyba as chyba17;
		rollback tran vtReg17;
	end;
	else
	begin
		save tran vtReg18;
	end
	exec ohodnotZapV 4, 2, @lastId, 1, @errMsg=@chyba output;
	if (not @chyba is null)
	begin
		select @chyba as chyba18;
		rollback tran vtReg18;
	end;
	else
	begin
		save tran vtReg19;
	end
	exec ohodnotZapV 2, 4, @lastId, 1, @errMsg=@chyba output;
	if (not @chyba is null)
	begin
		select @chyba as chyba19;
		rollback tran vtReg19;
	end;
	else
	begin
		save tran vtReg20;
	end
	exec ohodnotZapV 3, 5, @lastId, 1, @errMsg=@chyba output;
	if (not @chyba is null)
	begin
		select @chyba as chyba20;
		rollback tran vtReg20;
	end;
	else
	begin
		save tran vtReg21;
	end
	exec ohodnotZapV 5, 6, @lastId, 1, @errMsg=@chyba output;
	if (not @chyba is null)
	begin
		select @chyba as chyba21;
		rollback tran vtReg21;
	end;
	else
	begin
		save tran vtReg22;
	end
	exec ohodnotZapV 6, 7, @lastId, 1, @errMsg=@chyba output;
	if (not @chyba is null)
	begin
		select @chyba as chyba22;
		rollback tran vtReg22;
	end;
	else
	begin
		save tran vtReg23;
	end
	select * from hodnotenie_zap;
	exec vysledkyZap @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba23;
		rollback tran vtReg23;
	end;
	else
	begin
		save tran vtReg24
	end;
	exec vysledkyZap @lastId, 2, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba24;
		rollback tran vtReg24;
	end;
	else
	begin
		save tran vtReg25
	end;
	exec vysledkyZap @lastId, 4, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba25;
		rollback tran vtReg25;
	end;
	else
	begin
		save tran vtReg26
	end;
	exec vysledkyZap @lastId, 5, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba26;
		rollback tran vtReg26;
	end;
	else
	begin
		save tran vtReg27;
	end;
	exec vysledkyZap @lastId, 6, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba27;
		rollback tran vtReg27;
	end;
	else
	begin
		save tran vtReg28;
	end;
	exec vysledkyZap @lastId, 7, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba28;
		rollback tran vtReg28;
	end;
	else
	begin
		select * from stud_zap;
		select * from hodnotenie_zap;
		save tran vtReg29
	end;
	--purge
	--dbcc checkident('stud_zap', reseed, 4);
	--dbcc checkident('hodnotenie_zap', reseed, 4);
	select * from predmet order by vyucujici_id_uc
	exec vypisTerminSkusky 2, '17.02.2018', 'miesto a', 'SubeC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba29;
		rollback tran vtReg29;
	end;
	else
	begin
		save tran vtReg30;
	end;
	exec vypisTerminSkusky 3, '18.02.2018', 'miesto b', 'SmC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba30;
		rollback tran vtReg30;
	end;
	else
	begin
		save tran vtReg31;
	end;
	exec vypisTerminSkusky 5, '19.02.2018', 'miesto a', 'SqmC', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba31;
		rollback tran vtReg31;
	end;
	else
	begin
		save tran vtReg32;
	end;
	exec vypisTerminSkusky 6, '20.02.2018', 'miesto a', 'Sel1C', @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba32;
		rollback tran vtReg32;
	end;
	else
	begin
		save tran vtReg33;
	end;
	select * from zobraz_predmety_a_skusky
	--purge
	--delete from zkouska where id_zk > 3;
	--dbcc checkident('zkouska', reseed, 3);
	exec registrujNaSkusku @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba33;
		rollback tran vtReg33;
	end;
	else
	begin
		save tran vtReg34;
	end;	
	exec registrujNaSkusku @lastId, 3, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba34;
		rollback tran vtReg34;
	end;
	else
	begin
		save tran vtReg35;
	end;	
	exec registrujNaSkusku @lastId, 4, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba35;
		rollback tran vtReg35;
	end;
	else
	begin
		save tran vtReg36;
	end;	
	exec registrujNaSkusku @lastId, 5, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba36;
		rollback tran vtReg36;
	end;
	else
	begin
		save tran vtReg37;
	end;	
	exec registrujNaSkusku @lastId, 6, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba37;
		rollback tran vtReg37;
	end;
	else
	begin
		save tran vtReg38;
	end;	
	exec registrujNaSkusku @lastId, 7, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba38;
		rollback tran vtReg38;
	end;
	else
	begin
		save tran vtReg39;
	end;	
	select * from zkouska;
	exec skuskyStudenta @lastId, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba39;
		rollback tran vtReg39;
	end;
	else
	begin
		select * from stud_zk;
		save tran vtReg40;
	end;
	--purge
	--delete from stud_zk where id>2;
	--dbcc checkident('stud_zk', reseed, 2);
	exec ohodnotZkV 1, 1, @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba40;
		rollback tran vtReg40;
	end;
	else
	begin
		save tran vtReg41;
	end;
	exec ohodnotZkV 4, 3, @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba41;
		rollback tran vtReg41;
	end;
	else
	begin
		save tran vtReg42;
	end;
	exec ohodnotZkV 2, 4, @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba42;
		rollback tran vtReg42;
	end;
	else
	begin
		save tran vtReg43;
	end;
	exec ohodnotZkV 3, 5, @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba43;
		rollback tran vtReg43;
	end;
	else
	begin
		save tran vtReg44;
	end;
	exec ohodnotZkV 5, 6, @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba40;
		rollback tran vtReg40;
	end;
	else
	begin
		save tran vtReg41;
	end;
	exec ohodnotZkV 6, 7, @lastId, 1, @errMsg=@chyba output;
	if(not @chyba is null)
	begin
		select @chyba as chyba41;
		rollback tran vtReg41;
	end;
	else
	begin
		save tran vtReg42;
	end;
	exec vysledkyZk @lastId, 1, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba42;
		rollback tran vtReg42;
	end;
	else
	begin
		save tran vtReg43;
	end;
	exec vysledkyZk @lastId, 3, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba43;
		rollback tran vtReg43;
	end;
	else
	begin
		save tran vtReg44;
	end;
	exec vysledkyZk @lastId, 4, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba44;
		rollback tran vtReg44;
	end;
	else
	begin
		save tran vtReg45;
	end;
	exec vysledkyZk @lastId, 5, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba45;
		rollback tran vtReg45;
	end;
	else
	begin
		save tran vtReg46;
	end;
	exec vysledkyZk @lastId, 6, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba46;
		rollback tran vtReg46;
	end;
	else
	begin
		save tran vtReg46;
	end;
	exec vysledkyZk @lastId, 7, @errMsg=@chyba output
	if(not @chyba is null)
	begin
		select @chyba as chyba47;
		rollback tran vtReg47;
	end;
	else
	begin
		select * from zkouska;
		select * from hodn_zk;
		select * from stud_zk;
		save tran vtReg47;
	end;
	--purge
	--delete from stud_zk where 1=1;
	--dbcc checkident('stud_zk', reseed, 2);
	--delete from hodn_zk where 1=1;
	--dbcc checkident('hodn_zk', reseed, 2);
commit tran vtReg
go

