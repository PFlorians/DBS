use skuskova

-- Vytvoreni schemat
go
create schema Zakaznik authorization dbo
go
create schema Zamestnanci authorization dbo
go
create schema Objednavka authorization dbo
go
create schema Zbozi authorization dbo
go
create schema Dodavatel authorization dbo
go
create schema Faktura authorization dbo
go

------- VYTVORENI TABULEK --------------------------------------------------------------


Create Table Zakaznik.Identifikace(
ZakaznikID	int	identity (1,1),
NazevFirmy	varchar(50),		
ICO	varchar(8),		
DIC	varchar(10),		
UcetCislo varchar(20),		
Jmeno varchar(15),		
Prijmeni varchar (20),
Vlozeno	date not null CONSTRAINT DF_NullAddVlozeno DEFAULT getdate(),
CONSTRAINT PK_ZakaznikIdentifikace PRIMARY KEY (ZakaznikID)
)
go

Create Table Zakaznik.Kontakt (
KontaktZakID int identity (1,1),
ZakaznikID int,	
Ulice varchar (50)NOT NULL,
Mesto varchar (25) NOT NULL,
PSC	varchar	(6),
Telefon	varchar	(20),
Mobil varchar (20),
Email varchar (25),
Web varchar (50),
CONSTRAINT PK_ZakaznikKontakt PRIMARY KEY (KontaktZakID),
CONSTRAINT FK_zakaznikIdentikace_na_ZakaznikKontakt FOREIGN KEY (ZakaznikID)
REFERENCES Zakaznik.Identifikace (ZakaznikID)
)
go

Create Table Zamestnanci.Identifikace (
ZamestnanecID int identity (1,1),
Jmeno varchar (15) NOT NULL,
Prijmeni varchar (20) NOT NULL,
DatumNarozeni date NOT NULL,	
Nastup date NOT NULL,	
Vlozeno date not null CONSTRAINT DF_NullAddVlozeno DEFAULT getdate(),
CONSTRAINT PK_ZamestnanciIdentifikace PRIMARY KEY (ZamestnanecID)	
)
go

Create Table Zamestnanci.Kontakt (
KontaktZamID int identity (1,1),
ZamestnanecID int,	
Ulice varchar (50)NOT NULL,
Město varchar (25)NOT NULL,
PSC varchar (6)NOT NULL,
Telefon	varchar	(20),
Mobil varchar (20),
Email varchar (25)NOT NULL,
Web varchar (50),
CONSTRAINT PK_ZamestnanciKontakt PRIMARY KEY (KontaktZamID),	
CONSTRAINT FK_ZamestnanciIdentikace_na_ZamestnanciKontakt FOREIGN KEY (ZamestnanecID)
REFERENCES Zamestnanci.Identifikace (ZamestnanecID)
)
go

Create Table Zamestnanci.Funkce (
FunkceID int identity (1,1),
ZamestnanecID int,	
Zarazeni varchar (20)NOT NULL,
PracovniSkupina	varchar	(25) NOT NULL,
CONSTRAINT PK_ZamestnanciFunkce PRIMARY KEY (FunkceID),	
CONSTRAINT FK_ZamestnanciIdentikace_na_ZamestnanciFunkce FOREIGN KEY (ZamestnanecID)
REFERENCES Zamestnanci.Identifikace (ZamestnanecID)
)
go

create table Objednavka.Hlavicka (
ObjednavkaID int identity (1,1),
ZakaznikID	int,	
ZamestnanecID int,	
ObjednavkaDatum	date not null,	
CenabezZdph	money NOT NULL CHECK (CenabezZdph >= 0),	
CenabezSdph	money NOT NULL CHECK (CenabezSdph >= 0),	
CenabezOdph money NOT NULL CHECK (CenabezOdph >= 0),	
Zdph tinyint,	
Sdph tinyint,	
Odph tinyint,
CenaCelkemZdph as (CenabezZdph + (Zdph/100) *100),
CenaCelkemSdph as (CenabezSdph + (Sdph/100) *100),
CenaCelkemOdph as (CenabezOdph + (Odph/100) *100),	
CenaCelkem as (CenabezZdph + (Zdph/100) *100)+ (CenabezSdph + (Sdph/100) *100) + 
(CenabezOdph + (Odph/100) *100),
TypDodani tinyint,	
Uzavreno binary,	
Expedice date,
CONSTRAINT PK_ObjednavkaHlavicka PRIMARY KEY (ObjednavkaID),	
CONSTRAINT FK_ZamestnanciIdentikace_na_ObjednavkaHlavicka FOREIGN KEY (ZamestnanecID)
REFERENCES Zamestnanci.Identifikace (ZamestnanecID),
CONSTRAINT FK_ZakaznikIdentikace_na_ObjednavkaHlavicka FOREIGN KEY (ZakaznikID)
REFERENCES Zakaznik.Identifikace (ZakaznikID)
)
go

Create Table Zbozi.Kategorie (
KategorieID int identity (1,1),
ZboziKategorie int UNIQUE,
NazevKategorie varchar (30)NOT NULL,
CONSTRAINT PK_ZboziKategorie PRIMARY KEY (ZboziKategorie)	
)
go

Create Table Zbozi.Zbozi (
ZboziID	int	identity (1,1),
ZboziKategorie int NOT NULL,	
NazevZbozi varchar(60) NOT NULL,
MernaJednotka varchar(2) NOT NULL,
CenazaJednotku money NOT NULL,	
Dph tinyint NOT NULL,	
Marze tinyint NOT NULL,	
ProdejniCenazaJ	as (CenazaJednotku + (CenazaJednotku*Marze/100)),	
Nasklade int,
ZboziPopis varchar (250) SPARSE NULL,
CONSTRAINT PK_ZboziID PRIMARY KEY (ZboziID),	
CONSTRAINT FK_ZboziKategorie_na_ZboziZbozi FOREIGN KEY (ZboziKategorie)
REFERENCES Zbozi.Kategorie (ZboziKategorie)
)
go

Create Table Objednavka.Polozky (
PolozkyID int identity (1,1),
ObjednavkaID int,	
ZboziID	int,	
MernaJednotka varchar (2)NOT NULL,
CenazaJednotku money NOT NULL CHECK (CenazaJednotku > 0),	
Dph	tinyint NOT NULL,	
Mnozstvi int NOT NULL CHECK (Mnozstvi >= 1),	
Vyskladneno	date, 
CONSTRAINT PK_ObjednavkaPolozky_Objednavka_Zbozi PRIMARY KEY (PolozkyID, ObjednavkaID, ZboziID),	
CONSTRAINT FK_ObjednavkaHlavicka_na_ObjednavkaPolozky FOREIGN KEY (ObjednavkaID)
REFERENCES Objednavka.Hlavicka (ObjednavkaID),
CONSTRAINT FK_ZboziZbozi_na_ObjednavkaPolozky FOREIGN KEY (ZboziID)
REFERENCES Zbozi.Zbozi (ZboziID)
)
go

Create Table Dodavatel.Identifikace (
DodavatelID	int	identity (1,1),
NazevFirmy varchar (50),
ICO	varchar	(8),
DIC	varchar	(10),
UcetCislo varchar (20),
Web	varchar	(50),
Vlozeno	date not null CONSTRAINT DF_NullAddVlozeno DEFAULT getdate(),
CONSTRAINT PK_DodavatelIdentifikace PRIMARY KEY (DodavatelID)
)		
go

Create Table Dodavatel.Kontakt (
KontaktDodID int identity (1,1),
DodavatelID	int,	
Jmeno varchar (15),
Prijmeni varchar (20),
Ulice varchar (50) NOT NULL,
Mesto varchar (25) NOT NULL,
PSC	varchar	(6),
Telefon	varchar	(20) NOT NULL,
Mobil varchar (20),
Email varchar (25),
CONSTRAINT PK_DodavatelKOntakt PRIMARY KEY (KontaktDodID),	
CONSTRAINT FK_DodavatelIdentifikace_na_DodavatelKOntakt FOREIGN KEY (DodavatelID)
REFERENCES Dodavatel.Identifikace (DodavatelID)
)
go

Create Table Dodavatel.Zbozi (
DodavatelZboziID int identity (1,1),
ZboziID	int,	
DodavatelID	int,
CONSTRAINT PK_DodavatelZbozi_Zbozi_Dodavatel PRIMARY KEY (DodavatelZboziID, ZboziID, DodavatelID),	
CONSTRAINT FK_ZboziZbozi_na_DodavatelZbozi FOREIGN KEY (ZboziID)
REFERENCES Zbozi.Zbozi (ZboziID),
CONSTRAINT FK_DodavatelIdentifikace_na_DodavatelZbozi FOREIGN KEY (DodavatelID)
REFERENCES Dodavatel.Identifikace (DodavatelID)
)
go

Create Table Faktura.Zakaznik (
FakturaZakaznikID int identity (1,1),
CisloFakturyZak	int NOT NULL,	
ZamestnanecID int,	
DatumVystaveni date not null CONSTRAINT DF_NullAddDatumVystaveni DEFAULT getdate(),	
DatumPlneni date not null CONSTRAINT DF_NullAddDatumplneni DEFAULT getdate(),	
DatumSplatnosti date not null CONSTRAINT DF_NullAddVlozeno DEFAULT getdate()+14,	
CONSTRAINT PK_FakturaZakaznik PRIMARY KEY (FakturaZakaznikID),	
CONSTRAINT FK_ZamestnanciIdentifikace_na_FakturaZakaznik FOREIGN KEY (ZamestnanecID)
REFERENCES Zamestnanci.Identifikace (ZamestnanecID)
)
go

--- Vlozeni dat do tabulek ---

-- Vlozeni dat do tabulky Zakaznik.Identifikace
INSERT INTO Zakaznik.Identifikace (Jmeno,Prijmeni,UcetCislo,Vlozeno)
     VALUES ('Václav','Bednařík','11-11221122/0214',GETDATE())
INSERT INTO Zakaznik.Identifikace (Jmeno,Prijmeni,UcetCislo,Vlozeno)
     VALUES ('Martin','Hladký','125481/0365',GETDATE()-5)
INSERT INTO Zakaznik.Identifikace (Jmeno,Prijmeni,UcetCislo,Vlozeno)
     VALUES ('Petra','Janková','21-36985/3621',GETDATE()-120)
INSERT INTO Zakaznik.Identifikace (Jmeno,Prijmeni,UcetCislo,Vlozeno)
     VALUES ('Marek','Klimeš','12587412/6987',GETDATE()-135)
INSERT INTO Zakaznik.Identifikace (Jmeno,Prijmeni,UcetCislo,Vlozeno)
     VALUES ('Jana','Kamenská','12-36985225/0214',GETDATE()-140)
INSERT INTO Zakaznik.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Vlozeno)
     VALUES ('Bycicle4You s.r.o.','12123232','CZ12123232','124578/0365',GETDATE()-256)
INSERT INTO Zakaznik.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Vlozeno)
     VALUES ('B-C-K s.r.o.','21569874','CZ21569874','15288421/6987',GETDATE()-259)
INSERT INTO Zakaznik.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Vlozeno)
     VALUES ('MountBi a.s.','51269784','CZ51269784','3698472/1478',GETDATE()-278)
GO

-- Vlozeni dat do tabulky Zakaznik.Kontakt
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (1,'Purkyňova 85','Brno','61200','541897854','777999888','bednarik@bed.cz','NULL')
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (2,'Pěkná 2','Brno','64300','578963322','666111222','hladm@hlad.cz','http://www.hladm.info')
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (3,'Hamerská 874/21','Olomouc','77900','NULL','999333777','NULL','NULL')
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (4,'Lábkova 98','Plzeň','31800','654789977','333444222','marekk@klimec.cz','NULL')
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (5,'Výhon 15','Brno','63500','511987456','666114477','Janak@kamen.cz','NULL')
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (6,'Brněnská 478/15','Hradec Králové','50006','874446699','777232323','info@bycicle.cz','http://www.bycicle4you.eu')
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (7,'Pisárecká 2','Brno','63400','584497788','776113223','obchod@bck.cz','http://www.b-c-k.cz')
INSERT INTO Zakaznik.Kontakt (ZakaznikID,Ulice,Mesto,PSC,Telefon,Mobil,Email,Web)
     VALUES (8,'Vídeňská 124/3','Brno','61900','588774455','666212121','info@mountbi.cz','http://www.mountbi.cz')
GO     
     
-- Vlozeni dat do tabulky Dodavatel.Identifikace
INSERT INTO Dodavatel.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Web,Vlozeno)
     VALUES ('Jízdní kola s.r.o.','11223344','CZ11223344','11582233/0358','http://www.jizdnikola.cz',GETDATE()-141)
INSERT INTO Dodavatel.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Web,Vlozeno)
     VALUES ('Bike a.s.','33669988','CZ33669988','21-55774411/2144','http://bike.eu',GETDATE()-288)
INSERT INTO Dodavatel.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Web,Vlozeno)
     VALUES ('Kola - Kulíšek s.r.o.','78789966','CZ78789966','8811656/0358','http://kolakulisek.cz',GETDATE()-95)
INSERT INTO Dodavatel.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Web,Vlozeno)
     VALUES ('BI4Y s.r.o.','36365454','CZ36365454','4477896/1477','http://www.bi4y.eu',GETDATE()-64)
INSERT INTO Dodavatel.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Web,Vlozeno)
     VALUES ('Bycicle a.s.','44558878','CZ44558878','1144789/1878','http://www.bycicle.eu',GETDATE()-359)
INSERT INTO Dodavatel.Identifikace (NazevFirmy,ICO,DIC,UcetCislo,Web,Vlozeno)
     VALUES ('Clean s.r.o.','11444444','CZ11444444','11117788/3214','http://www.clean.cz',GETDATE())
GO

-- Vlozeni dat do tabulky Dodavatel.Kontakt
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (1,'Jan','Novosad','Provazníkova 55','Brno','61300','544889963','777889955','novosad@jizdnikola.cz')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (2,'Petra','Černá','Martinská 874/1','Přerov','75002','325144477','666778899','obchod@bike.eu')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (3,'Karel','Kulíšek','Těšínská 78','Opava','74601','745895445','333887722','kulisek@kolakulisek.cz')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (4,'Jana','Zámečníková','Staňkova 36','Brno','61200','541112233','696545423','info@bi4y.eu')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (5,'Iva','Studená','Píškova 12','Brno','63500','533989862','777989863','studena@bycicle.eu')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (1,'Pavel','Kučera','Provazníkova 55','Brno','61300','544889963','776878741','kucera@jizdnikola.cz')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (1,'Iveta','Novosadová','Provazníkova 55','Brno','61300','544889963','776232355','novosadova@jizdnikola.cz')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (3,'Dana','Malá','Těšínská 78','Opava','74601','745895456','333334477','malad@kolakulisek.cz')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (5,'Martina','Vaňková','Píškova 12','Brno','63500','533989862','777635522','vankova@bycicle.eu')
INSERT INTO Dodavatel.Kontakt (DodavatelID,Jmeno,Prijmeni,Ulice,Mesto,PSC,Telefon,Mobil,Email)
     VALUES (6,'Bohumila','Čistá','Ulrychova 97','Brno','62400','522221459','777363625','info@clean.cz')     
GO

--- Vlozeni dat do tabulky Zbozi.Kategorie
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (10,'Horská kola')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (20,'Silniční kola')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (30,'Krosová kola')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (40,'Dětská kola')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (50,'Doplňky na kola')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (60,'Přilby a helmy')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (70,'Nosiče na kola')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (80,'Díly na kola')
INSERT INTO Zbozi.Kategorie (ZboziKategorie, NazevKategorie)
     VALUES (90,'Ostatní')
GO

--- Vlozeni dat do tabulky Zbozi.Zbozi
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (10,'Horské kolo Merida MATTS HFS XC PRO 5000-D','ks',69000,20,30,1,'Kvalitní závodní kolo Merida MATTS HFS XC PRO 5000-D s pevným rámem, výbavou Shimano.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (10,'Horské kolo Merida MATTS TFS XC 700-V model 2009','ks',16200,20,30,2,'Vysoce kvalitní kolo TFS Merida MATTS TFS XC 700-V s výbavou Shimano.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (10,'Dámské horské kolo Dema Ravena model 2010','ks',8700,20,30,2,'Dámské horské kolo Dema Ravena model 2010. Speciální dámská geometrie tohoto rámu zajistí přirozenější a vzpřímený posed.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (10,'Horské kolo Dema Asti model 2009','ks',11650,20,30,5,'Sportovní horské kolo s osvědčeným hliníkovým rámem, odpruženou vidlicí Rock Shox.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (10,'Horské kolo Apache Canyon Lady','ks',4980,20,30,4,'Apache Canyon Lady. Turistické kolo na občasné vyjížďky s odpruženou vidlicí na Alloy 6061 dámském rámu.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (20,'Silniční kolo Dema ALVITO model 2010','ks',12690,20,30,3,'Silniční kolo Dema ALVITO s rámem DEMA Alloy 6061-T6.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (20,'Silniční kolo Merida Road Ride 880-24 silver model','ks',9760,20,30,5,'Silniční kolo Merida Road Ride 880-24 speed, vyvynuté pro pohodlnější jízdu a určené k silniční turistice.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (20,'Silniční kolo Trek 4.5 Madone T model 2010','ks',9760,20,30,1,'Silniční kolo Trek 4.5 Madone T model 2010 s TCT Carbon rámem.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (30,'Cyklocrosové kolo Merida Cyclo Cross 4 model 2010','ks',28630,20,30,1,'Cyklocrosové kolo Merida Cyclo Cross 4 s Cyclo Cross-Lite-single rámem.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (30,'Jízdní kolo Merida Cyclo Cross 4 model 2009','ks',57400,20,30,1,'Sportovní cyklokrosové kolo Merida Cyclo Cross 4 na lehkém rámu s výbavou Shimano.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (40,'Dětské kolo Apache A-16','ks',3750,20,30,4,'Dětská 16" Apache A-16" CAT je kvalitní kolo s Al rámem a balančními kolečky.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (40,'Dětské kolo Apache Fireball 24" model 2010','ks',6400,20,30,6,'Dětské kolo Apache Fireball 24" model 2010 s masivnější rámem.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Computer Sigma Sport BC 1009','ks',630,20,35,10,'9 funkční computer Sigma Sport BC 1009.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Zadní nosič Art. 207 na kola s kotoučovou brzdou','ks',399,20,35,6,'Zadní nosič na kola s kotoučovou brzdou.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Blatník FORPLAST treking plast','ks',138,20,35,6,'Blatník na crossové nebo trekingové kolo.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Blatník Polisport Colorado','ks',170,20,35,3,'Blatník Polisport Colorado je pár plastových blatníků určených pro kola v rozměru 24"-26".')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Blatník SKS X-TRA-DRY','ks',170,20,35,2,'Zadní blatník oddělatelný na MTB.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Blikač SMART 301WW','ks',299,20,35,12,'Pření blikač s ledkou.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Blikač SMART 403R','ks',220,20,35,12,'Zadní blikač s ledkou.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (50,'Brašna do rámu Art. 504 střední','ks',220,20,35,7,'Upevňuje se na rám kola pomocí suchých zipů.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (60,'Přilba Bell Alchera','ks',1654,20,35,8,'Oblíbená silniční helma s výborným systémem odvětrávávní.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (60,'Přilba Bell Amigo','ks',899,20,35,14,'Dětská helma se štítkem pro ochranu obličeje.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (70,'Střešní autonosič kol černý','ks',542,20,35,3,'Určené pro motáž na střechu auta.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (80,'Karbonová silniční vidlice PZ Racing CR2.2','ks',2150,20,40,2,'Karbonová silniční vidlice.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (80,'Tlumič FOX DHX 5.0 model 2009','ks',7856,20,40,2,'Tlumič na kolo.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (80,'Řídítka ControlTech Carbon Comp','ks',4580,20,40,4,'Silniční řídítka s karbonovým vláknem.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (80,'Pedál Exustar SPD ložiskový','ks',1265,20,40,8,'Ložiskový pedál s hladkým chodem.')
INSERT INTO Zbozi.Zbozi (ZboziKategorie, NazevZbozi,MernaJednotka,CenazaJednotku,Dph,Marze,Nasklade,ZboziPopis)
     VALUES (80,'Duše PRO-T 125','ks',79,20,40,15,'Duše pro horská kola.')
GO
-- Vlozeni dat do tabulky Dodavatel.Zbozi
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (1,2)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (2,2)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (3,1)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (4,1)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (5,1)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (6,4)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (7,4)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (8,4)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (9,4)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (10,2)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (11,1)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (12,1)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (13,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (14,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (15,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (16,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (17,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (18,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (19,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (20,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (21,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (22,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (23,3)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (24,5)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (25,5)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (26,5)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (27,5)
INSERT INTO Dodavatel.Zbozi (ZboziID,DodavatelID)
     VALUES (28,5)
GO
SELECT * FROM Zakaznik.Identifikace
SELECT * FROM zakaznik.kontakt  
SELECT * FROM Dodavatel.Identifikace
SELECT * FROM dodavatel.Kontakt
SELECT * FROM Zbozi.Kategorie
SELECT * FROM zbozi.zbozi
SELECT * FROM Dodavatel.zbozi
GO
-- pohlad
create view souhrn
as
select di.NazevFirmy, zk.NazevKategorie, case
									when zk.KategorieID between 5 and 8 then upper ('Příslušenství')
									when zk.KategorieID between 1 and 4 then upper('kolo')
									else upper('Ostatní')
									end as Kategorie,
	sum(zz.Nasklade) as SKLAD, sum(zz.CenazaJednotku)*sum(zz.Nasklade) as NAKUP, sum(zz.ProdejniCenazaJ)*sum(zz.Nasklade) as PRODEJ,
		((sum(zz.ProdejniCenazaJ)*sum(zz.Nasklade))-(sum(zz.CenazaJednotku)*sum(zz.Nasklade))) as ROZDIL
	from Zbozi.Zbozi as zz right outer join Zbozi.Kategorie as zk on zz.ZboziKategorie=zk.ZboziKategorie
	 left outer join Dodavatel.Zbozi as dz on dz.ZboziID=zz.ZboziID left outer join Dodavatel.Identifikace as di
		on di.DodavatelID=dz.DodavatelID
	where not zk.NazevKategorie is null
	group by zk.NazevKategorie, di.NazevFirmy, zk.KategorieID;
go
begin tran t
	select * from souhrn order by NazevFirmy asc;
rollback tran t
go
create proc Souhrn_Kategorie
@kategorie as varchar(255)
as
select s.Kategorie, s.NazevKategorie, sum(s.SKLAD), sum(s.PRODEJ) - sum(s.NAKUP) as MARZE, ((sum(s.PRODEJ) - sum(s.NAKUP))/sum(s.NAKUP))*100 as [%]
		 from souhrn as s
		 where s.Kategorie like @kategorie
		 group by s.NazevKategorie, s.Kategorie;
go
begin tran t1
	select * from souhrn order by NazevFirmy, NazevKategorie asc;

	exec Souhrn_Kategorie 'KOLO';
	exec Souhrn_Kategorie 'OSTATNÍ';
	exec Souhrn_Kategorie 'PŘÍSLUŠENSTVÍ';
rollback tran t1
go
begin tran t2
	select * from Dodavatel.Identifikace as di  left outer join Dodavatel.Zbozi as dz on di.DodavatelID=dz.DodavatelID
		full join Zbozi.Zbozi as zz on zz.ZboziID = dz.ZboziID
			order by di.DodavatelID
	--join 
	select datediff(day, getdate(), convert(datetime, '12.04.2018', 104))
	select datepart(month, getdate())
rollback tran t2

go
-- cvicny trigger
use master
drop trigger Dodavatel.[zaloha];
select * from dodavatel.kontakt
use skuskova

create trigger zaloha
	on Dodavatel.Kontakt
	for delete
	as
			declare @meno as varchar(15);
			declare @priez as varchar(20);
			declare @email as varchar(25);

			--select ss.name as [schema], st.name as tabulka, sc.column_id, sc.name as stlpec 
			--	from sys.columns as sc inner join sys.tables as st on sc.object_id=st.object_id
			--	inner join sys.schemas as ss on ss.schema_id=st.schema_id
			--	group by ss.name, st.name, sc.column_id, sc.name
			--	 order by ss.name, st.name asc;
				 --select SQL_VARIANT_PROPERTY(SQL_VARIANT_PROPERTY('retazec', 'MaxLength'), 'BaseType')

	if('zaloha_kontakt' in (select name from sys.tables))
	begin				  
		declare kur cursor scroll for select Jmeno, Prijmeni, Email from zaloha_kontakt;
		insert into zaloha_kontakt(DodavatelID, Jmeno, Prijmeni,Ulice, Mesto, PSC, Telefon, Mobil, Email)
			(select d.DodavatelID, d.Jmeno, d.Prijmeni, d.Ulice, d.Mesto, d.PSC, d.Telefon, d.Mobil, d.Email from deleted as d)
			--vypis tabulky cez kurzor
			
			open kur;
			fetch first from kur into @meno, @priez, @email;
			while @@FETCH_STATUS = 0
			begin
				select @meno + ' ' + @priez + ' ' + @email as [bleskove info]
				fetch next from kur into @meno, @priez, @email;
			end;
			close kur;
			deallocate kur;
	end;
	else
	begin
		select 'gotcha';
			create table zaloha_kontakt(
					id int identity(1, 1) primary key,
					DodavatelID int,
					Jmeno varchar (15),
					Prijmeni varchar (20),
					Ulice varchar (50) NOT NULL,
					Mesto varchar (25) NOT NULL,
					PSC	varchar	(6),
					Telefon	varchar	(20) NOT NULL,
					Mobil varchar (20),
					Email varchar (25)
				);
				declare kur cursor scroll for select Jmeno, Prijmeni, Email from zaloha_kontakt;
				insert into zaloha_kontakt(DodavatelID, Jmeno, Prijmeni,Ulice, Mesto, PSC, Telefon, Mobil, Email)
			(select d.DodavatelID, d.Jmeno, d.Prijmeni, d.Ulice, d.Mesto, d.PSC, d.Telefon, d.Mobil, d.Email from deleted as d)
			--vypis tabulky cez kurzor
			open kur;
			fetch first from kur into @meno, @priez, @email;
			while @@FETCH_STATUS = 0
			begin
				select @meno + ' ' + @priez + ' ' + @email as [bleskove info]
				fetch next from kur into @meno, @priez, @email;
			end;
			close kur;
			deallocate kur;
	end;
go
create table #tmp1(
	id int identity(1, 1) primary key,
	text varchar(255)
);
create trigger zaloha_tmp
	on Zbozi.Zbozi
	for delete
	as
	select * from [tempdb].INFORMATION_SCHEMA.TABLES
	select * from [tempdb].sys.tables
	select * from sys.tables
	select sc.name, sc.max_length ,sst.name, sst.system_type_id from sys.columns as sc join sys.tables as st on st.object_id=sc.object_id 
		join sys.types as sst on sst.system_type_id=sc.system_type_id
	where st.name like 'Zbozi';
	
	drop table [tempdb].#tmp1
	if('zbozi_tmp' in(select name from [tempdb].sys.tables))
	begin

	end;
	else
	begin
		
	end;
go
create view suhrn
as
	select di.NazevFirmy, zk.NazevKategorie, case
											when zk.KategorieID between 1 and 4 then 'KOLO'
											when zk.KategorieID between 5 and 8 then 'PŘÍSLUŠENSTVÍ'
											else 'OSTATNÍ'
											end as KATEGORIE,
			 sum(zz.Nasklade) as SKLAD, 
			sum(zz.CenazaJednotku) as KUPA, SUM(zz.ProdejniCenazaJ) as PREDAJ, SUM(zz.ProdejniCenazaJ)-SUM(zz.CenazaJednotku) as MARZA
	 from Dodavatel.Identifikace as di left outer join Dodavatel.Zbozi as dz
		on dz.DodavatelID = di.DodavatelID left outer join Zbozi.Zbozi as zz on zz.ZboziID=dz.ZboziID
		left outer join Zbozi.Kategorie as zk on zk.ZboziKategorie = zz.ZboziKategorie
		group by di.NazevFirmy, zk.NazevKategorie, zk.KategorieID;
go
select * from suhrn order by NazevFirmy asc;
go
alter procedure suhrn_dod
@Firma varchar(255) = null
as
	if(not @Firma is null)
	begin
		select s.NazevFirmy, s.KATEGORIE as [hlavní kategorie], s.NazevKategorie, sum(s.SKLAD), (sum(s.MARZA)/sum(s.KUPA))*100 
		from suhrn as s
			where NazevFirmy like @firma
			group by s.NazevFirmy, s.KATEGORIE, s.NazevKategorie;
	end;
	else
	begin
		select 'ZADANÉMU KRITÉRIU NODPOVÍDÁ ŽÁDNÁ FIRMA';
	end;
go
--tst
exec suhrn_dod '%a.s.';
exec suhrn_dod '%S.R.O.';
exec suhrn_dod;
go
begin tran t4
delete from Dodavatel.Kontakt where KontaktDodID = 10;
select * from Dodavatel.Kontakt;
select * from zaloha_kontakt;
rollback tran t4
