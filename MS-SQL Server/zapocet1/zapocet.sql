use skuskova;
go
create view [PŘEHLED ZBOŽÍ] as
select zk.NazevKategorie, zz.NazevZbozi, zz.CenazaJednotku, zz.ProdejniCenazaJ, zz.Nasklade [počet kusu na sklade],
di.NazevFirmy, dk.Mesto, ((zz.ProdejniCenazaJ-zz.CenazaJednotku))*((convert(real, zz.Marze)/100)) as [Marže],
((zz.ProdejniCenazaJ-zz.CenazaJednotku))*((convert(real, zz.Dph)/100)) as DPH, 
(zz.ProdejniCenazaJ-zz.CenazaJednotku + (((zz.ProdejniCenazaJ-zz.CenazaJednotku))*((convert(real, zz.Marze)/100))) 
+ (((zz.ProdejniCenazaJ-zz.CenazaJednotku))*((convert(real, zz.Dph)/100)))) as [celkova cena], zz.Marze
from Zbozi.Kategorie as zk
join Zbozi.Zbozi as zz on zk.ZboziKategorie=zz.ZboziKategorie
join Dodavatel.Zbozi as dz on dz.ZboziID=zz.ZboziID
join Dodavatel.Identifikace as di on di.DodavatelID=dz.DodavatelID
join Dodavatel.Kontakt as dk on dk.DodavatelID=di.DodavatelID
group by zk.NazevKategorie, zz.NazevZbozi,zz.CenazaJednotku, zz.ProdejniCenazaJ, zz.Nasklade, di.NazevFirmy, dk.Mesto, zz.Marze, zz.Dph
;
go
select [počet kusu na sklade], [celkova cena] from [PŘEHLED ZBOŽÍ]
order by NazevKategorie, [celkova cena] desc
go
alter proc calculation
@sadzbaBrno as real = null,
@sadzbaOthers as real=null

as
declare @nazev as varchar(255);
declare @obrat as real;
declare @firma as varchar(255);
declare @celkMarz as real;
declare @provizeBrno as real;
declare @provizeOstatni as real;

declare celkovyObrat cursor scroll for select NazevKategorie, NazevFirmy, ([počet kusu na sklade]*[celkova cena]) as [celkovy obrat] from [PŘEHLED ZBOŽÍ] order by NazevKategorie, NazevFirmy asc;

--celkovy obrat vypis
	open celkovyObrat;
	fetch next from celkovyObrat into @nazev, @firma, @obrat;
	while @@FETCH_STATUS = 0
	begin
		print 'Nazev Kategorie: ' + convert(varchar, @nazev) + ' Nazev Firmy: ' + @firma + ' Obrat: ' + convert(varchar, @obrat);
		fetch next from celkovyObrat into @nazev, @firma, @obrat;
	end;
	close celkovyObrat;
	deallocate celkovyObrat;
	print '------------------------------------------------------------'
--marza a provize
	-- brno def
	if(not @sadzbaBrno is null) --nema vyznam ak nemam percento provizie
	begin
		declare celkMarzaBrno cursor scroll for select sum(Marže*[počet kusu na sklade]) as [celkova marza] from [PŘEHLED ZBOŽÍ]
												where Mesto like '%Brno%'
												group by NazevKategorie, NazevFirmy
												order by NazevKategorie, NazevFirmy asc;
		open celkMarzaBrno;
		fetch next from celkMarzaBrno into @celkMarz;
		while @@FETCH_STATUS =0
		begin
			set @provizeBrno = @celkMarz * @sadzbaBrno;
			print 'Celkova marza: ' +  convert(varchar, @celkMarz) + ' provize Brno: ' + convert(varchar, @provizeBrno);
			fetch next from celkMarzaBrno into @celkMarz;
		end;
		close celkMarzaBrno;
		deallocate celkMarzaBrno;
	end;
	print '------------------------------------------------------------'
	if(not @sadzbaOthers is null)--to iste len provizia ostatnych
	begin
		declare celkMarzaOthers cursor scroll for select sum(Marže*[počet kusu na sklade]) as [celkova marza] from [PŘEHLED ZBOŽÍ]
												where not Mesto like '%Brno%'
												group by NazevKategorie, NazevFirmy
												order by NazevKategorie, NazevFirmy asc;
		open celkMarzaOthers;
		fetch next from celkMarzaOthers into @celkMarz;
		while @@FETCH_STATUS =0
		begin
			set @provizeOstatni = @celkMarz * @sadzbaOthers;
			print 'Celkova Marza: ' + convert(varchar, @celkMarz) + ' provize ostatni: ' + convert(varchar, @provizeOstatni);
			fetch next from celkMarzaOthers into @celkMarz;
		end;
		close celkMarzaOthers;
		deallocate celkMarzaOthers;
	end;
go
begin tran t
	exec calculation 0.05, 0.10;
rollback tran t
