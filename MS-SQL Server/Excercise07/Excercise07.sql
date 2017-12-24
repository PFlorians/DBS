-- kapitola 3
-- ukol 3.1
--join
select jmeno, prijmeni, nazev 
	from 
	skola.ucitel join skola.vyucujici on skola.ucitel.id_ucitel=skola.vyucujici.id_ucitel
	left outer join skola.predmet on skola.vyucujici.id_predmet=skola.predmet.id_predmet;
go
--where
select jmeno, prijmeni, nazev 
	from skola.ucitel as u, skola.predmet as p, skola.vyucujici as v
	where (u.id_ucitel=v.id_ucitel) and (v.id_predmet=p.id_predmet);
go
-- ukol 3.2
--innner select
select jmeno +' '+ prijmeni as [Jmeno]
	from skola.ucitel as u
	where not exists
	(
		select * from skola.vyucujici as v 
		where u.id_ucitel=v.id_ucitel
	);
go
--join isnull
select jmeno, prijmeni
	from 
	skola.ucitel left join skola.vyucujici on skola.ucitel.id_ucitel=skola.vyucujici.id_ucitel
	where skola.vyucujici.id_ucitel is null;
go
--3.3 

select jmeno, prijmeni, body
	from skola.znamka as z, skola.student as s
	where z.id_student=s.id_student
go
--join
select jmeno, prijmeni, body
	from skola.student as s join skola.znamka as z
		on s.id_student = z.id_student;
go
-- 3.4
select jmeno, prijmeni, body, nazev
	from skola.student as s left join skola.znamka as z 
		on s.id_student = z.id_student 
	left join skola.predmet as p on z.id_predmet=p.id_predmet;
go
-- agregacne fkcie
-- 3.5
select p.nazev, count(p.nazev) as [Počet], avg(body) [Průměr], sum(body) as Suma, min(body) as Minimum, max(body) as Maximum
	from skola.predmet as p join skola.znamka as z
		on p.id_predmet = z.id_predmet
group by p.nazev;
go
-- 3.6
select prijmeni, count(nazev) as [Počet], avg(body) as prumer, min(body) as Minimum, max(body) as Maximum
	from skola.student as s join skola.znamka as z 
		on s.id_student = z.id_student
		join skola.predmet as p 
			on p.id_predmet = z.id_predmet
	group by prijmeni;
go
-- 3.7
select u.jmeno+' ' +u.prijmeni as [Jméno učitele], z.body, p.nazev, s.jmeno + ' '+s.prijmeni as [Jméno studenta]
	from skola.ucitel as u join skola.znamka as z
		on u.id_ucitel = z.id_ucitel
		 join skola.student as s
			on z.id_student = s.id_student
				join skola.predmet as p
					on z.id_predmet = p.id_predmet;
go
-- 3.8
select distinct u.jmeno +' ' +u.prijmeni as [Jméno učitele]
	from skola.ucitel as u join skola.znamka as z
		on u.id_ucitel = z.id_ucitel
		 join skola.student as s
			on z.id_student = s.id_student
				join skola.predmet as p
					on z.id_predmet = p.id_predmet
	where s.jmeno like 'Jarda';
go
-- kap 4
-- 4.1 
create view Prehled as
	select u.jmeno+' ' +u.prijmeni as [Jméno učitele], z.body, p.nazev, s.jmeno + ' '+s.prijmeni as [Jméno studenta]
	from skola.ucitel as u join skola.znamka as z
		on u.id_ucitel = z.id_ucitel
		 join skola.student as s
			on z.id_student = s.id_student
				join skola.predmet as p
					on z.id_predmet = p.id_predmet;
go
-- 4.2
select [Jméno učitele], body
	from Prehled
	where [Jméno studenta] like '%Novák';
go
-- 4.3
select [Jméno učitele], nazev, body
	from Prehled
	where ([Jméno studenta] like '%Novák') or ([Jméno studenta] like '%Pořízek');
go
-- 4.4
select [Jméno studenta], body, nazev
	from Prehled
	where (body >= 60 and nazev like 'mat%') or (body <= 20 and nazev like 'chemie');
