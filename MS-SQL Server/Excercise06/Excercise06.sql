use MI_Florians_Patrik_Cvicna
go
-- 1. zobrazení všech informací o čtenářích
select * from
	knihovna.ctenar;
go
-- 2. zobrazení jména, příjmení a věku čtenáře
select jmeno, prijmeni, vek from
	knihovna.ctenar;
go
-- 3. zobrazení výpůjček, které ještě nebyly vráceny
select * from 
	knihovna.vypujcka as vyp
	where
		vyp.vraceno is null;
go
-- 4. zobrazení výpůjček, které byly vráceny
select * from 
	knihovna.vypujcka as vyp
	where
		vyp.vraceno is not null;
go
-- 5. zobrazení neplnoletých čtenářů
select * from
	knihovna.ctenar as ct
	where 
		ct.vek < 18;
go
-- 6. zobrazení čtenářů starších 60ti let
select * from
	knihovna.ctenar as ct
	where 
		ct.vek > 60;
go
-- 7. zobrazenípříjmení a města u čtenářů starších 10ti let a mladších 40ti let.
-- Záznamy seřaďte nejdříve podle příjmení (A..Z)
select * from
	knihovna.ctenar as ct
	where 
		(ct.vek >= 10 AND ct.vek<40)
	order by ct.prijmeni ASC;
go
-- 8. zobrazení jména a příjmení všech autorů - jako jedné položky pojmenované Jméno a příjmení autora
-- Záznamy seřaďte nejdříve podle příjmení (Z..A) a pak podle jména (A..Z)
select (jmeno +' '+ prijmeni) as [Jméno a příjmení autora]  from
		knihovna.autor
		order by prijmeni DESC, jmeno ASC;
go
-- 9. zobrazení ID a ISBN u knih jejichž název je Broučci
select ID, ISBN 
	from knihovna.kniha
	where nazev LIKE 'Broučci';
go
-- 10. zobrazení čtenářů starších 10ti let a mladších 40ti let, kteří jsou z Brna
select *
	from knihovna.ctenar as ct
	where ct.mesto like '%Brno%' AND 
	(ct.vek > 10 AND ct.vek<60);
go
-- 11. S využitím funkce doplňte ke jménu a příjmení čtenáře (zobrazené v jednom poli pojmenované jméno a příjmení)
-- i kategorii do které patří: věk do 17let - neplnoletý, věk 18-60let - plnoletý, věk nad 60let - důchodce)
select (ct.jmeno +' '+ ct.prijmeni) as [Jméno a příjmení], 
		(case 
			when ct.vek <= 17 then 'neplnoletý'
			when ct.vek >=18 AND ct.vek <=60 then 'plnoletý'
			else 'důchodce'
		END) as kategorie
	  from
		knihovna.ctenar as ct 
		order by ct.prijmeni DESC, ct.jmeno ASC;
go
-- 12. Vyzkoušejte si další jednoduché dotazy dle přednášky (např. práce s datem, s texty, s jednoduchými agregačními funkcemi apod.)
select (au.jmeno + ' ' + au.prijmeni) as Autor, 
		kn.nazev as Nazev, 
		ct.jmeno as [Jmeno Ctenare], ct.prijmeni as [Prijmeni Ctenare], 
		vyp.od as Od, vyp.do as Do, datediff(day, vyp.od, vyp.do) as [doba výpůjčky]
	from knihovna.autor as au 
		inner join knihovna.kniha as kn 
			on au.id=kn.autor
		inner join knihovna.vypujcka as vyp
			on vyp.id_kniha = kn.id
		inner join knihovna.ctenar as ct
			on vyp.id_ctenar = ct.id	
		order by Autor DESC;
