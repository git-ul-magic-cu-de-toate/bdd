/*************************************************** COLOCVIU 1 - NR 1 ***************************************************/
/*
Pentru fiecare furnizor/supplier (CompanyName) afisati:
	1. care este produsul cel mai vandut
*/
with UnitsPerProduct as 
				(select s.CompanyName as cname, p.ProductName as pname, sum(od.Quantity) as units
				from Suppliers s
				join Products p on s.SupplierID = p.SupplierID
				join [Order Details] od on od.ProductID = p.ProductID
				group by s.CompanyName, p.ProductName),

	 MaxUnitsProduct as
				(select cname, max(units) as max_units
				from UnitsPerProduct
				group by cname)

select upp.cname, upp.pname, upp.units
from UnitsPerProduct upp
join MaxUnitsProduct mup on upp.cname = mup.cname and upp.units = mup.max_units
order by upp.cname;

/*
Pentru fiecare furnizor/supplier (CompanyName) afisati:
	2. daca furnizorul este "relevant" sau "marginal":
		- relevant = valoarea totala a produselor livrate depaseste media globala a vanzarilor tuturor furnizorilor.
		- marginal = nu depaseste
*/
declare @min_value float;

select s.CompanyName as cname, sum(od.Quantity * od.UnitPrice) as total_value
into SuppliersSales
from Suppliers s
join Products p on p.SupplierID = s.SupplierID
join [Order Details] od on od.ProductID = p.SupplierID
group by s.CompanyName;

select @min_value = AVG(total_value) from SuppliersSales;

select
	ss.cname nume_companie,
	case
		when total_value > @min_value then 'relevant'
		else 'marginal'
	end as evaluare_furnizor
from SuppliersSales ss;

drop table SuppliersSales;

/*
Pentru fiecare furnizor/supplier (CompanyName) afisati:
	3. produsul cel mai bine vandut pentru fiecare furnizor, dar doar daca produsul a fost comandat in cel putin 20 de locatii distincte (ShipCity)
*/
-- numarul total de unitati vandute pentru fiecare produs al fiecarui furnizor
with UnitsPerProduct as
				(select s.CompanyName as cname, p.ProductName as pname, sum(od.Quantity) as units
				from Suppliers s
				join Products p on s.SupplierID = p.SupplierID
				join [Order Details] od on od.ProductID = p.ProductID
				group by s.CompanyName, p.ProductName),
-- numarul de orase distincte in care a fost comandat fiecare produs, filtrand produsele care au mai putin de 20 orase
	 CitiesPerProduct as
				(select s.CompanyName as cname, p.ProductName as pname, count(distinct o.ShipCity) as cities_count
				from Suppliers s
				join Products p on s.SupplierID = p.SupplierID
				join [Order Details] od on od.ProductID = p.ProductID
				join Orders o on od.OrderID = o.OrderID
				group by s.CompanyName, p.ProductName
				having count(distinct o.ShipCity) >= 20),
-- tabel combinat, contine furnizor - produs - unitati - orase
	Combined as
				(select upp.cname as cname, upp.pname as pname, upp.units as units, cpp.cities_count as cities_count
				from UnitsPerProduct upp
				join CitiesPerProduct cpp on upp.cname = cpp.cname and upp.pname = cpp.pname)

select c1.cname, c1.pname, c1.units, c1.cities_count
from Combined c1
where
	c1.units = (select max(c2.units)
				from Combined c2
				where
					c2.cname = c1.cname);

/*
Pentru fiecare furnizor/supplier (CompanyName) afisati:
	4. daca furnizorul a livrat produse catre cel putin 5 categorii distincte (da/nu)
*/
with ProductsOfSupplier as
	(select s.CompanyName cname, p.ProductName pname, p.CategoryID cat
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID),

	Counts as 
	(select cname company_name, count(distinct cat) distinct_categoryes
	from ProductsOfSupplier
	group by cname)

select company_name, (case when distinct_categoryes >= 5 then 'da' else 'nu' end) as 'are cel putin 5 categorii'
from Counts;

/*
Pentru fiecare furnizor/supplier (CompanyName) afisati:
	5. care este cel mai popular produs de la furnizor, cumparat de clientii noi in mai multe tari
*/
with Newcustomer as
	(select s.CompanyName, c.CustomerID
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID
	join Customers c on o.CustomerID = c.CustomerID
	group by s.CompanyName, c.CustomerID
	having count (o.OrderID) = 1),

	UnitsPerProduct as
	(select s.CompanyName, p.ProductName, sum(od.Quantity) as units
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID
	join Newcustomer nc on s.CompanyName = nc.CompanyName and o.CustomerID = nc.CustomerID
	group by s.CompanyName, p.ProductName
	),

	MaxUnitsPerSupplier AS (
		SELECT CompanyName, MAX(units) AS max_units
		FROM UnitsPerProduct
		GROUP BY CompanyName
	)

SELECT up.CompanyName, up.ProductName, up.units
FROM UnitsPerProduct up
JOIN MaxUnitsPerSupplier mu ON up.CompanyName = mu.CompanyName AND up.units = mu.max_units
order by up.CompanyName;




/*************************************************** COLOCVIU 1 - NR 2 ***************************************************/
/*
Pentru fiecare tara afisati:
	1. categoria cu cele mai mari vanzari
*/
with CountrySale as
	(select s.Country cname, p.CategoryID cid, sum(od.Quantity * od.UnitPrice) total_sales
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join [Order Details] od on od.ProductID = p.ProductID
	group by s.Country, p.CategoryID)

select cname, cid, cat.CategoryName
from CountrySale c1
join Categories cat on c1.cid = cat.CategoryID
where total_sales = (select max(total_sales) from CountrySale c2 where c2.cname = c1.cname)
order by cname;

/*
Pentru fiecare tara afisati:
	2. daca este tara target afisati 'target', altfel afisati 'normal'
	- target = valoarea totala a comenzilor depaseste media valorilor comenzilor pe toate tarile
*/
with CountrySales as
	(select s.Country country, sum(od.Quantity * od.UnitPrice) sales_value
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join [Order Details] od on p.ProductID = od.ProductID
	group by s.Country)

select country, case when sales_value > (select avg(sales_value) from CountrySales) then 'target' else 'normal' end as is_target
from CountrySales;

/*
Pentru fiecare tara afisati:
	3. furnizorii care au livrat produse discontinue din cel putin 2 categorii diferite
*/
with DiscontinuedProductsSuppliers as
	(select s.Country country, s.CompanyName company, count(distinct p.CategoryID) as category_count
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	where p.Discontinued = 1
	group by s.Country, s.CompanyName)


select country, company, category_count
from DiscontinuedProductsSuppliers
where category_count >= 2;

/*
Pentru fiecare tara afisati:
	4. daca valoarea totala a comenzilor depaseste cel putin 20% valoarea medie globala a comenzilor (da/nu)
*/
with CountriesSales as
	(select s.Country country, sum(od.Quantity * od.UnitPrice) sales
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join [Order Details] od on p.ProductID = od.ProductID
	group by s.Country)

select country, case when sales  > 1.2 *  (select avg(sales) from CountriesSales) then 'da' else 'nu' end as 'depaseste cu cel putin 20% val medie'
from CountriesSales
order by country;

/*
Pentru fiecare tara afisati:
	5. cea mai profitabila locatie de livrare (orasul care a produs cei mai multi bani, dar ia in considerare doar orasele in care au fost cel putin 20 de livrari);
	o locatie este profitabila doar daca are concurenta (in tara respectiva exista cel putin 2 orase in care se fac livrari).
*/
with WantedCities as
	(select o.ShipCountry country,  o.ShipCity city, count(distinct o.OrderID) orders
	from Orders o
	group by o.ShipCountry, o.ShipCity
	having
		count(distinct o.OrderID) >= 20),
	
	ProfitableCities as
	(select wc.country country, wc.city city
	from WantedCities wc
	where wc.country in (	select country
							from WantedCities
							group by country
							having count (distinct city) >= 2)
	),

	ProfitableCitiesProfits as
	(select pc.country country, pc.city city, sum(od.Quantity * od.UnitPrice) profits
	from ProfitableCities pc
	join Orders o on o.ShipCity = pc.city
	join [Order Details] od on o.OrderID = od.OrderID
	group by pc.country, pc.city)


select *
from ProfitableCitiesProfits pcp
where pcp.profits = (	select max(pcp2.profits)
						from ProfitableCitiesProfits pcp2
						where pcp2.country = pcp.country);
						



/*************************************************** COLOCVIU 2 - NR 1 ***************************************************/
/*
Pentru fiecare supplier vrem sa aflam:
	1. orasul cu cele mai multe comenzi.
*/
with ComenziPerOras as
	(select s.CompanyName company, o.ShipCity shipcity, count(o.OrderID) orders
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID
	group by s.CompanyName, o.ShipCity
	)

                                                                                                                                                                                               
select cpo.company, cpo.shipcity
from ComenziPerOras cpo
where cpo.orders = (select max (orders)
					from ComenziPerOras cpo2
					where cpo2.company = cpo.company)
order by cpo.company;

/*
Pentru fiecare supplier vrem sa aflam:
	2. cea mai veche comanda.
*/
with OrdersOfCompany as
	(select s.CompanyName company, o.OrderDate order_date
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on o.OrderID = od.OrderID
	group by s.CompanyName, o.OrderDate)

select *
from OrdersOfCompany oc
where
	oc.order_date = (	select min(oc2.order_date)
									from OrdersOfCompany oc2
									where oc2.company = oc.company)
order by company;


/*
Pentru fiecare supplier vrem sa aflam:
	3. produsele cu pretul peste media preturilor tuturor produselor din baza de date.
*/
with SupplierProducts as
	(select s.CompanyName company, p.ProductID prodid
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	group by s.CompanyName, p.ProductID)

select company, p.ProductName
from SupplierProducts sp
join Products p on p.ProductID = sp.prodid
where p.UnitPrice > (	select avg(p2.UnitPrice)
						from Products p2);

/*
Pentru fiecare supplier vrem sa aflam:
	4. daca furnizorul a livrat produse in cel putin 10 regiuni distincte; afisati da/nu.
*/
with SupplierRegions as
	(select s.CompanyName company, count(distinct o.ShipRegion) regions
	from Suppliers s
	join Products p on p.SupplierID = s.SupplierID
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on o.OrderID = od.OrderID
	group by s.CompanyName)

select company, case when (regions >= 10) then 'da' else 'nu' end
from SupplierRegions
order by company;

/*
Pentru fiecare supplier vrem sa aflam:
	5. categoria de produse care este cea mai vanduta in peste 50% din tari si cel mai vandut produs asociat acestei categorii.
*/
with WantedCategories as
	(select p.CategoryID catid, count(distinct o.ShipCountry) count
	from Products p
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID
	group by p.CategoryID
	having count(distinct o.ShipCountry) > (select count(distinct ShipCountry) from Orders) / 2),

	ValueSoldPerCategory as
	(select s.CompanyName company, wc.catid catid, sum(od.Quantity * od.UnitPrice) value_sold
	from Suppliers s
	join Products p on s.SupplierID = p.SupplierID
	join WantedCategories wc on p.CategoryID = wc.catid
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID
	group by s.CompanyName, wc.catid
	),

	BestSoldCategory as
	(select company, catid
	from ValueSoldPerCategory vpc
	where vpc.value_sold = (select max(vpc2.value_sold)
						from ValueSoldPerCategory vpc2
						where
							vpc2.company = vpc.company)),

	BestSoldProduct as
	(select s.CompanyName company, bsc.catid catid, p.ProductName prod, sum(od.Quantity) units_sold
	from Products p
	join Suppliers s on s.SupplierID = p.SupplierID
	join BestSoldCategory bsc on p.CategoryID = bsc.catid
	join [Order Details] od on od.ProductID = p.ProductID
	group by s.CompanyName, bsc.catid, p.ProductName)

select bsp.company, bsp.prod, c.CategoryName, bsp.units_sold
from BestSoldProduct bsp
join Categories c on c.CategoryID = bsp.catid
where bsp.units_sold = (select max(bsp2.units_sold)
						from BestSoldProduct bsp2
						where
							bsp.company = bsp2.company)
order by bsp.company;




/***************************************************  COLOCVIU 2 - NR 2 ***************************************************/
/*
Pentru fiecare produs vrem sa aflam:
	1. in cate regiuni diferite a fost vandut
*/
with CountRegions as
	(select p.ProductName productname, count( o.ShipRegion) regioncount
	from Products p
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID
	group by p.ProductName)

select *
into #ex1
from CountRegions;

/*
Pentru fiecare produs vrem sa aflam:
	2. cea mai scumpa comanda plasata
*/
with MaxOrderValue as
	(select p.ProductName productname, max(od.quantity * od.unitprice) as maxvaluesold
	from Products p
	join [Order Details] od on p.ProductID = od.ProductID
	group by p.ProductName)

select maxvalue.productname productname, maxvalue.orderid maxvalueorder
into #ex2
from
	(select p.ProductName productname, o.OrderID orderid
	from Products p
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on o.OrderID = od.OrderID
	where od.Quantity * od.UnitPrice = (select maxvaluesold
										from MaxOrderValue mov
										where p.ProductName = mov.productname)) maxvalue;

/*
Pentru fiecare produs vrem sa aflam:
	3. daca face parte dintr o categorie top; adica o categorie cu vanzari de peste 15k in ultima luna, in cel putin 17 regiuni; se afiseaza da/nu.
*/
with LastMonthPerCat as
	(select p.CategoryID as cat, year(max(o.OrderDate)) as last_year, month(max(o.OrderDate)) as last_month
	from Products p
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on o.OrderID = od.OrderID
	group by p.CategoryID),

	LastMonthOrders as
	(select p.CategoryID category, o.OrderID, o.ShipREgion, o.OrderDate, od.UnitPrice, od.Quantity
	from Products p
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on od.OrderID = o.OrderID
	join LastMonthPerCat lm on p.CategoryID = lm.cat and year(o.OrderDate) = lm.last_year and month(o.OrderDate) = lm.last_month),

	TopCat as
	(select lm.category, sum(lm.UnitPrice * lm.Quantity) value_sold, count(lm.ShipRegion) regions
	from LastMonthOrders lm
	group by lm.category
	having sum(lm.UnitPrice * lm.Quantity) > 15000 and count(lm.ShipRegion) >= 17)

select p.ProductName, case when tc.category is not null then 'da' else 'nu'end as topcat
into #ex3
from Products p
left join TopCat tc on p.CategoryID = tc.category;

/*
Pentru fiecare produs vrem sa aflam:
	4. care este cea mai profitabila locatie (ShipCity) pentru acest produs
*/
with ProductCitiesValues as
	(select p.ProductName, o.ShipCity, sum(od.Quantity * od.UnitPrice) city_value
	from Products p
	join [Order Details] od on od.ProductID = p.ProductID
	join Orders o on o.OrderID = od.OrderID
	group by p.ProductName, o.ShipCity),
	
	ProductMaxCityValue as
	(select pcv.Productname, max(pcv.city_value) maxval
	from ProductCitiesValues pcv
	group by pcv.ProductName
	)
	
select pcv.ProductName, pcv.ShipCity
into #ex4
from ProductCitiesValues pcv
join ProductMaxCityValue mcv on mcv.ProductName = pcv.ProductName and mcv.maxval = pcv.city_value;

/*
Pentru fiecare produs vrem sa aflam:
	5. Daca este cel mai vandul produs dintre cele livrate de cei mai bine cotati livratori. Cei mai bine
	cotati livratori inseamna ca livreaza in peste 85% din tari; afisati da/nu
*/
WITH ShipperCoverage AS (
    -- Calculăm numărul total de țări în care livrează fiecare livrator
    SELECT 
        s.ShipperID,
        COUNT(DISTINCT o.ShipCountry) AS country_count
    FROM 
        Shippers s
    JOIN Orders o ON o.ShipVia = s.ShipperID
    GROUP BY 
        s.ShipperID
),
TotalCountries AS (
    -- Calculăm numărul total de țări
    SELECT COUNT(DISTINCT ShipCountry) AS total_countries
    FROM Orders
),
TopShippers AS (
    -- Selectăm livratorii care livrează în cel puțin 85% din țări
    SELECT 
        sc.ShipperID
    FROM 
        ShipperCoverage sc
    CROSS JOIN TotalCountries tc
    WHERE sc.country_count >= 0.85 * tc.total_countries
),
ProductSalesByTopShippers AS (
    -- Calculăm cantitățile totale vândute pentru fiecare produs de către livratorii de top
    SELECT 
        p.ProductName,
        SUM(od.Quantity) AS total_quantity
    FROM 
        Products p
    JOIN [Order Details] od ON p.ProductID = od.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    JOIN TopShippers ts ON o.ShipVia = ts.ShipperID
    GROUP BY 
        p.ProductName
),
MaxSoldProduct AS (
    -- Determinăm produsul cel mai vândut dintre cele livrate de livratorii de top
    SELECT 
        ps.ProductName,
        CASE 
            WHEN ps.total_quantity = (
                SELECT MAX(total_quantity)
                FROM ProductSalesByTopShippers
            ) THEN 'Da'
            ELSE 'Nu'
        END AS is_top_seller
    FROM 
        ProductSalesByTopShippers ps
)
-- Rezultatul final
SELECT 
    msp.ProductName,
    msp.is_top_seller
INTO #ex5
FROM MaxSoldProduct msp;

select ex1.productname, ex1.regioncount ex1_regions_sold_in, ex2.maxvalueorder ex2_max_val_ord, ex3.topcat ex3_is_top_cat, ex4.ShipCity ex4_most_profitable_city, ex5.is_top_seller ex5_is_top_seller
from #ex1 ex1
join #ex2 ex2 on ex1.productname = ex2.productname
join #ex3 ex3 on ex1.productname = ex3.ProductName
join #ex4 ex4 on ex1.productname = ex4.ProductName
join #ex5 ex5 on ex1.productname = ex5.productname
order by productname;

drop table #ex1;
drop table #ex2;
drop table #ex3;
drop table #ex4;
drop table #ex5;




/*************************************************** COLOCVIU 3 - NR 2 ***************************************************/
/*
Pentru fiecare angajat sa se afiseze:
	1. Ultimul ciclu de studii absolvit, astfel:
		- daca 'BA' sau 'BS' sau 'BSC' se regasesc pe Employees.Notes se va afisa 'Licenta'
		- 'MA' sau 'MBA' => 'Master'
		- 'Ph.D' => 'Doctorat'
		- altfel, lipsa informatii
		- daca se regaseste mai mult de o diploma, o vom afisa doar pe cea mai superioara ('BA' si 'MA' => 'Master')
*/
with Studies as
	(select
		e.FirstName + ' ' + e.LastName name,
		case
			when CHARINDEX('Ph.D', e.Notes) > 0 then 'Doctorat'
			when CHARINDEX('MA', e.Notes) > 0 or CHARINDEX('MBA', e.Notes) > 0  then 'Master'
			when CHARINDEX('BA', e.Notes) > 0 or CHARINDEX('BS', e.Notes) > 0 or CHARINDEX('BSC', e.Notes) > 0 then 'Licenta'
			else 'lipsa informatii'
		end as studii
	from Employees e)

select * from Studies
order by name;

/*
Pentru fiecare angajat sa se afiseze:
	2. care este cel mai mare discount in bani acordat pe o comanda (pretul unei comenzi se calculeaza ca UnitPrice * Quantity, dupa care se aplica discount);
	o intrare in Order are mai multe intrari in OrderDetails - pentru fiecare produs din acelasi Order exista o intrare diferita in OrderDetails
*/
with OrdersOfEmp as
	(select e.EmployeeID empid, o.OrderID ordid
	from Employees e
	join Orders o on o.EmployeeID = e.EmployeeID),

	OrdersDiscounts as
	(select od.OrderID ordid, sum(od.Quantity * od.UnitPrice * od.Discount) discount_value
	from [Order Details] od
	group by od.OrderID)

select ooe.empid, max(od.discount_value) as max_discount
from OrdersOfEmp ooe
join OrdersDiscounts od on ooe.ordid = od.ordid
group by ooe.empid
order by ooe.empid;

/*
Pentru fiecare angajat sa se afiseze:
	3. diferenta absoluta maxima dintre numarul total de produse ale aceluiasi supplier vandute intr-o luna vs luna precedenta in care a mai fost vandut;
	ex: in iunie 1988 - 50 produse ale supplier 1; iulie 1988 - 60 produse ale supplier 1, deci diferenta este de 10 produse;
		in august 1988 - 0 produse ale supplier 1; seprembrie 1988 - 5 produse ale supplier 1, deci diferenta este de 55 produse;
		=> diferenta maxima este de 55 produse
*/
with SupplierMonthlySale as
	-- numarul total de produse vandute pt fiecare employee, pt fiecare supplier, pe ani, pe luni
	(select e.EmployeeID empid, s.SupplierID supid, YEAR(o.ShippedDate) yearof, MONTH(o.ShippedDate) monthof, sum(od.Quantity) units_sold
	from Orders o
	join Employees e on e.EmployeeID = o.EmployeeID
	join [Order Details] od on od.OrderID = o.OrderID
	join Products p on p.ProductID = od.ProductID
	join Suppliers s on s.SupplierID = p.SupplierID
	where o.ShippedDate is not null
	group by e.EmployeeID, s.SupplierID, YEAR(o.ShippedDate), MONTH(o.ShippedDate)
	),

	-- numarul total de produse vandute pt fiecare employee, pt fiecare supplier, pe ani, pe luni + luna precedenta
	SupplierMonthlySaleLag as
	(select sms.*, LAG(units_sold) over (	partition by empid, supid
											order by yearof, monthof) as prev_units_sold
	from SupplierMonthlySale sms
	),

	-- diferentele dintre luni pentru numarul total de produse vandute pt fiecare employee, pt fiecare supplier
	Diff as
	(select smsl.*, abs(coalesce(smsl.units_sold, 0) - coalesce(smsl.prev_units_sold, 0)) diff_of_units
	from SupplierMonthlySaleLag smsl)

select diff.empid, max(diff_of_units) as max_diff_of_units
from Diff diff
group by diff.empid
order by empid;

/*
Pentru fiecare angajat sa se afiseze:
	4. bonusul de performanta, care se calculeaza astfel:
		- daca angajatul a vandut macar 3 produse care se afla in 'stoc suficient', adica Products.UnitsInStock > mai mare decat media valorilor din Products.UnitsInStock
		pentru toate produsele aflate in colaborare active, adica Products.Discontinued = 0 => primeste 60 lei per produs
		- daca angajatul are nivelul ierarhic 2, adica are macar un manager in subordine, care la randul lui are angajati in subordine => primeste 1000 lei
		- daca este in top 30% angajati de acelasi sex (Mr./Mrs.) care sunt "rapizi" (in functie de valoarea medie a duratei de livrare, numarul de zile dintre Orders.ShippedDate si Orders.OrderDate)
		primeste 1100 lei
		- altfel, nu primeste nimic
*/
-- Media produselor active în stoc
with
    AvgStock as
    (select avg(Products.UnitsInStock) as avg_units_in_stock
     from Products
     where Products.Discontinued = 0),

-- Produse vândute în "stoc suficient" de fiecare angajat
    SufficientStockSales as
    (select e.EmployeeID as empid, count(distinct od.ProductID) as products_sold
     from Orders o
     join Employees e on o.EmployeeID = e.EmployeeID
     join [Order Details] od on o.OrderID = od.OrderID
     join Products p on p.ProductID = od.ProductID
     join AvgStock a on p.UnitsInStock > a.avg_units_in_stock
     where p.Discontinued = 0
     group by e.EmployeeID),

-- Angajați de nivel ierarhic 2
    Level2Employees as
    (select e.EmployeeID as empid
     from Employees e
     where exists (
         select 1
         from Employees m
         where m.ReportsTo = e.EmployeeID
           and exists (
               select 1
               from Employees sub
               where sub.ReportsTo = m.EmployeeID
           )
     )),

-- Angajați rapizi (top 30% pe gen, după durata medie de livrare)
    FastEmployees as
    (select empid
     from (
         select e.EmployeeID as empid, 
                e.TitleOfCourtesy as gender, 
                avg(datediff(day, o.OrderDate, o.ShippedDate)) as avg_delivery_time,
                ntile(10) over (partition by e.TitleOfCourtesy order by avg(datediff(day, o.OrderDate, o.ShippedDate))) as decile
         from Employees e
         join Orders o on o.EmployeeID = e.EmployeeID
         where o.ShippedDate is not null
         group by e.EmployeeID, e.TitleOfCourtesy
     ) as ranked
     where decile <= 3),

-- Calcularea bonusurilor pentru fiecare angajat
	PerformanceBonus as
    (select e.EmployeeID as empid,
            case 
                when ss.products_sold >= 3 then 60 * ss.products_sold
                when e2.empid is not null then 1000
                when fe.empid is not null then 1100
                else 0
            end as bonus
     from Employees e
     left join SufficientStockSales ss on e.EmployeeID = ss.empid
     left join Level2Employees e2 on e.EmployeeID = e2.empid
     left join FastEmployees fe on e.EmployeeID = fe.empid)

select *
from PerformanceBonus;

-- Select final combinat
select 
    s.name,
	s.studii,
    coalesce(md.max_discount, 0) as max_discount,
    coalesce(mdif.max_diff_of_units, 0) as max_diff_of_units,
    coalesce(pb.bonus, 0) as bonus
from 
    Studies s
left join 
    MaxDiscount md on s.empid = md.empid
left join 
    MaxDiff mdif on s.empid = mdif.empid
left join 
    PerformanceBonus pb on s.empid = pb.empid
order by 
    s.name;




/*************************************************** COLOCVIU 4 - NR 1 ***************************************************/
use northwind;
go

IF OBJECT_ID('ex1', 'U') IS NOT NULL DROP TABLE ex1;
IF OBJECT_ID('ex2', 'U') IS NOT NULL DROP TABLE ex2;
IF OBJECT_ID('ex3', 'U') IS NOT NULL DROP TABLE ex3;

/*
Pentru fiecare angajat se afiseaza:
	1. nr de comenzi primite de angajat cum mai mult de 27 de ani si 2 luni in urma
*/
with OldOrders as(
    SELECT 
        e.EmployeeID as EmployeeID,
        e.FirstName + ' ' + e.LastName as EmployeeName,
        count(o.OrderID) as OldOrdersCount
    from Employees e 
    left join Orders o 
        on o.EmployeeID = e.EmployeeID 
    where o.OrderDate < DATEADD(MONTH, -326, GETDATE()) -- 27 de ani si 2 luni in urma 
    group by e.EmployeeID, e.FirstName, e.LastName
) 

select EmployeeID, EmployeeName, OldOrdersCount
into ex1
from OldOrders;

/*
Pentru fiecare angajat se afiseaza:
	2. Care dintre comenzile primite este cea mai ieftina dupa aplicarea discount-ului
	(pretul se calculeaza OrderDetails.UnitPrice * OrderDetails.Quantity) dupa care se aplica discountul
*/
with CheapestOrder as(
    select 
        e.EmployeeID as EmployeeID,
        e.FirstName + ' ' + e.LastName as EmployeeName,
        o.OrderID as OrderID,
        sum((od.Quantity * od.UnitPrice) * (1.0 - od.Discount)) as PriceDiscount
    from Employees e 
    join Orders o 
        on e.EmployeeID = o.EmployeeID 
    join [Order Details] od 
        on od.OrderID = o.OrderID
    group by e.EmployeeID, e.FirstName, e.LastName, o.OrderID
),
Ranked as(
    select 
        EmployeeID,
        EmployeeName,
        OrderID,
        row_number() over(partition by EmployeeName order by PriceDiscount asc) as rank 
    from CheapestOrder
)

select EmployeeName, EmployeeID, OrderID  
into ex2
from Ranked 
where rank = 1;

/*
Pentru fiecare angajat se afiseaza:
	3. diferenta absoluta maxima dintre numarul total de produse (OrderDetails.Quantity) din aceeasi categorie vandute vandute intr-o 
	luna vs luna precedenta in care a mai fost vandut
	ex: in iunie 1988 au fost vandute 50 de produse din categoria 1,
		in iulie 1988 au fost vandute 60 de produse din categoria 1,
		=> deci diferenta este de 10 produse;
	ex: in august 1988 nu au fost vandute produse din categoria 1,
		iar in septembrie 1988 au fost vandute doar 5 produse din cateogoria 1,
		=> deci diferenta este 55 produse;
	Data la care sunt vandute comenzile este Orders.OrderDate.
*/
with MonthlyCategorySales as(
    SELECT 
        p.CategoryID as CategoryID,
        c.CategoryName as CategoryName,
        YEAR(o.OrderDate) as Year,
        Month(o.OrderDate) as Month,
        sum(od.Quantity) as TotalProducts
    FROM Orders o 
    JOIN [Order Details] od 
        on o.OrderID = od.OrderID 
    Join Products p 
        on od.ProductID = p.ProductID 
    Join Categories c 
        on p.CategoryID = c.CategoryID
    GROUP BY p.CategoryID, c.CategoryName, Year(o.OrderDate), Month(o.OrderDate)
),
CategoryDifferences AS (
    select 
        CategoryID,
        CategoryName,
        TotalProducts - LAG(TotalProducts, 1) over (partition by CategoryName order by Year,Month) as Difference 
    From MonthlyCategorySales
),
MaxCategoryDifferences as(
    SELECT 
        CategoryID,
        CategoryName,
        MAX(ABS(Difference)) as MaxDifference
    FROM CategoryDifferences
    where difference IS NOT NULL 
    Group by CategoryID, CategoryName
)

Select CategoryID, CategoryName, MaxDifference 
into ex3
from MaxCategoryDifferences;

select 
    ex1.EmployeeName,
    ex1.OldOrdersCount as 'Nr comenzi cele mai vechi',
    ex2.OrderID as 'Cea mai ieftina comanda dupa discount',
    ex3.CategoryName,
    ex3.MaxDifference as 'Diferenta absoluta maxima'
from ex1 
left join ex2 
    on ex1.EmployeeID = ex2.EmployeeID 
left join ex3 
    on 1=1;



/*************************************************** COLOCVIU 5 - NR ? ***************************************************/
/* 
Pentru fiecare client, afiseaza:
	1. numarul de comenzi date (Orders.OrderID), cu conditia sa aiba minim 3 produse diferite (Products.ProductID);
	daca nu exista, afisati "-"
*/
with NumOfOrd as
	(select c.CustomerID customer, count(valid_orders.OrderID) orders
	from Customers c
	left join Orders o on c.CustomerID = o.CustomerID
	left join (	select od.OrderID, count (distinct od.ProductID) as product_count
				from [Order Details] od
				group by od.OrderID
				having count (distinct od.ProductID) >= 3
		 ) valid_orders on o.OrderID = valid_orders.OrderID
	group by c.CustomerID)

select customer, case when orders = 0 then '-' else cast(orders as nvarchar(10)) end as orders
into #ex1
from NumOfOrd;

/* 
Pentru fiecare client, afiseaza:
	2. care este categoria "cea mai raspandita" pentru cea mai recenta comanda plasata 
	(ex. daca intr-o comanda sunt 10 produse din categoria 1 si 90 de produse din categoria 2,
	se va afisa categoria 2)
*/
WITH MostRecent AS (
    SELECT 
        c.CustomerID AS customer, 
        o.OrderID AS mostrecentorder
    FROM Customers c
    LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
    WHERE o.OrderDate = (
        SELECT MAX(o2.OrderDate)
        FROM Orders o2
        WHERE o2.CustomerID = c.CustomerID
    )
),
CategoryCounts AS (
    SELECT 
        mr.customer, 
        p.CategoryID, 
        COUNT(*) AS product_count
    FROM MostRecent mr
    JOIN [Order Details] od ON mr.mostrecentorder = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
    GROUP BY mr.customer, p.CategoryID
),
MaxCategory AS (
    SELECT 
        cc.customer, 
        cc.CategoryID
    FROM CategoryCounts cc
    WHERE cc.product_count = (
        SELECT MAX(cc2.product_count)
        FROM CategoryCounts cc2
        WHERE cc2.customer = cc.customer
    )
)
SELECT 
    mc.customer, 
    mc.CategoryID AS most_spread_category
INTO #ex2
FROM MaxCategory mc;

/* 
Pentru fiecare client, afiseaza:
	3. raportul minim dintre suma de bani cheltuita de client intr-o luna si suma de bani cheltuita de client in urmatoarea luna in care a mai avut o comanda 
	(ex. clientul 1 are 3 comenzi in iunie 1988 in valoare de 500; 
	in iulie 1988 are o comanda in valoare de 1000 ron; raportul este 500/1000 = 0.5; 
	in august 1988 nu a dat nicio comanda; 
	in septembrie 1988 a dat 6 comenzi in valoare de 10 ron; raportul este 1000/10 = 100; raportul minim este 0.5). 
	
	Pretul unei comenzi se calculeaza ca Order_Details.UnitPrice * Order_Details.Quantity, 
	dupa care se aplica discountul (Order_Details.Discount);

	ATENTIE: relatia dintre Orders si Order_Details este "one to many".
	Data la care se extrag banii este Orders.ShippedDate.
*/
WITH MonthlySpending AS (
    SELECT 
        o.CustomerID AS customer,
        YEAR(o.ShippedDate) AS year,
        MONTH(o.ShippedDate) AS month,
        SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS total_spending
    FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE o.ShippedDate IS NOT NULL
    GROUP BY o.CustomerID, YEAR(o.ShippedDate), MONTH(o.ShippedDate)
)
, MonthlyDifferences AS (
    SELECT 
        ms.customer,
        ms.year,
        ms.month,
        ms.total_spending,
        LAG(ms.total_spending) OVER (
            PARTITION BY ms.customer 
            ORDER BY ms.year, ms.month
        ) AS previous_spending
    FROM MonthlySpending ms
)
, MinRatios AS (
    SELECT 
        md.customer,
        MIN(ABS(md.total_spending / NULLIF(md.previous_spending, 0))) AS min_ratio
    FROM MonthlyDifferences md
    WHERE md.previous_spending IS NOT NULL
    GROUP BY md.customer
)
SELECT 
    mr.customer,
    mr.min_ratio
INTO #ex3
FROM MinRatios mr;

SELECT 
    ex1.customer,
    ex1.orders AS number_of_orders,
    ex2.most_spread_category,
    ex3.min_ratio AS min_monthly_spending_ratio
FROM #ex1 ex1
LEFT JOIN #ex2 ex2 ON ex1.customer = ex2.customer
LEFT JOIN #ex3 ex3 ON ex1.customer = ex3.customer;



/*************************************************** PREGATIRE ***************************************************/
/*
Pentru fiecare locatie (city) afisati:
	1. Care este cel mai bine platit job = 1p
*/
WITH CelMaiBinePlatit AS (
    SELECT
        l.city AS NumeLocatie,
        e.job_id AS CelMaiBinePlatitJob,
        ROW_NUMBER() OVER (PARTITION BY l.city ORDER BY e.salary DESC) AS RowNum
    FROM locations l
    LEFT JOIN departments d ON l.location_id = d.location_id
    LEFT JOIN employees e ON e.department_id = d.department_id
)

SELECT 
    NumeLocatie,
    COALESCE(CelMaiBinePlatitJob, '-') AS CelMaiBinePlatitJob
INTO #CelMaiBinePlatit
FROM CelMaiBinePlatit
WHERE RowNum = 1;


/*
Pentru fiecare locatie (city) afisati:
  2. Care este job-ul cel mai des schimbat (functia schimbata in job_history, daca nu e niciuna puneti "-") = 2p
*/
with JobSchimbat as
	(select l.city as NumeLocatie, jh.job_id as JobSchimbat, count(distinct jh.job_id) as counts
	from locations l
	left join departments d on l.location_id = d.location_id
	left join employees e on d.department_id = e.department_id
	left join job_history jh on e.job_id = jh.job_id
	group by l.city, jh.job_id)

select
	js.NumeLocatie, coalesce(js.JobSchimbat, '-') JobSchimbat
into #JobSchimbat
from JobSchimbat js
where js.counts = (select max(counts) from JobSchimbat js2 where js.NumeLocatie = js2.NumeLocatie);


/*
Pentru fiecare locatie (city) afisati:
  3. Care este job-ul cu cea mai mare margine de promovare (ne uitam cat se mai poate aloca din grila salariala;
  vedem ce procent este salariul actual ca suma fata de count*sal_max) = 3p
*/
with Margine as
	(select l.city as NumeLocatie,
			e.job_id as JobMargine,
			sum(e.salary) * 1.0 / (count(e.job_id) * max(j.max_salary)) as procentgrila
	from locations l
	left join departments d on d.location_id = l.location_id
	left join employees e on e.department_id = d.department_id
	left join jobs j on j.job_id = e.job_id
	group by l.city, e.job_id)

select
	NumeLocatie,
	JobMargine
into #JobMargine
from 
	(select NumeLocatie,
			JobMargine,
			row_number() over (partition by NumeLocatie order by procentgrila desc) as rownum
	from Margine) RankedMargins
where
	rownum = 1;

/*
Pentru fiecare locatie (city) afisati:
  4. Care este job-ul cel mai performant; 1p de performanta / angajat daca are:
      - salariul minim 70% din sal_max, 
      - venitul minim 75% 
      - macar un manager cu acel job
*/
WITH JobPerformanta AS (
    SELECT 
        l.city AS NumeLocatie,
        e.job_id AS JobPerformanta,
        COUNT(e.employee_id) AS NrAngajati,
        CASE 
            WHEN MIN(e.salary) >= 0.7 * MAX(j.max_salary)
                 AND AVG(e.salary) >= 0.75 * MAX(j.max_salary)
                 AND COUNT(DISTINCT e.manager_id) > 0 
            THEN 1
            ELSE 0
        END AS Performanta
    FROM locations l
    LEFT JOIN departments d ON l.location_id = d.location_id
    LEFT JOIN employees e ON e.department_id = d.department_id
    LEFT JOIN jobs j ON j.job_id = e.job_id
    GROUP BY l.city, e.job_id
),
TopPerformanta AS (
    SELECT 
        NumeLocatie,
        JobPerformanta,
        ROW_NUMBER() OVER (PARTITION BY NumeLocatie ORDER BY Performanta DESC, NrAngajati DESC) AS RowNum
    FROM JobPerformanta
)
SELECT 
    NumeLocatie,
    JobPerformanta
INTO #JobPerformanta
FROM TopPerformanta
WHERE RowNum = 1;

-- grupare in tabel final
SELECT
    cbp.NumeLocatie, 
    cbp.CelMaiBinePlatitJob, 
    js.JobSchimbat, 
    jm.JobMargine, 
    jp.JobPerformanta
FROM #CelMaiBinePlatit cbp
LEFT JOIN #JobSchimbat js ON cbp.NumeLocatie = js.NumeLocatie
LEFT JOIN #JobMargine jm ON cbp.NumeLocatie = jm.NumeLocatie
LEFT JOIN #JobPerformanta jp ON cbp.NumeLocatie = jp.NumeLocatie;

DROP TABLE #CelMaiBinePlatit;
DROP TABLE #JobSchimbat;
DROP TABLE #JobMargine;
DROP TABLE #JobPerformanta;

