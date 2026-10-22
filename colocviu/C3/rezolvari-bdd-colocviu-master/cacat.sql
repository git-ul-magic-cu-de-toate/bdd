use northwind;
go

-- marti nr1
-- Analiza performanței pe furnizori. Pentru fiecare furnizor (CompanyName), afișați:

-- ex 1 Care este produsul cel mai vândut

drop table if exists Counts;
drop table if exists Ranked;

select s.CompanyName as company, p.ProductName as product, count(*) as count
into Counts
from Suppliers as s
    join Products as p on s.SupplierID = p.SupplierID
    join [Order Details] as od on p.ProductID = od.ProductID
group by s.CompanyName, p.ProductName;

select company, product, count, row_number() over (partition by company order by count desc) as rank
into Ranked
from counts;

select company, product, count
from ranked
where rank = 1;

-- ex2 Dacă furnizorul este "relevant" sau "marginal": Un furnizor este "relevant" dacă valoarea totală
-- a produselor (OrderDetails.Quantity *OrderDetails.UnitPrice) livrate depășește media globală a vânzărilor pe furnizori.

drop table if exists SupplierRevenues;

select s.CompanyName as company, sum(od.Quantity * od.UnitPrice) as revenue
into SupplierRevenues
from Suppliers as s
    join Products as p on s.SupplierID = p.SupplierID
    join [Order Details] as od on p.ProductId = od.ProductID
group by s.CompanyName

declare @globalMean float
select @globalMean = avg(revenue)
from SupplierRevenues

select company,
    case
        when revenue > @globalMean then 'RELEVANT'
        else 'MARGINAL'
    end as tip
from SupplierRevenues;

-- ex3 Produsul cel mai bine vândut (ProductName) pentru fiecare furnizor, dar doar dacă produsul a fost comandat
-- în cel puțin 20 locații distincte (ShipCity).

drop table if exists BestByCities;
select
    s.CompanyName as company,
    p.ProductName as product,
    sum(od.Quantity * od.UnitPrice) revenue,
    count(distinct o.ShipCity) as countCities
into BestByCities
from Suppliers as s
    join Products as p on s.SupplierId = p.SupplierId
    join [Order Details] as od on p.ProductId = od.ProductId
    join Orders as o on od.OrderId = o.OrderId
group by s.CompanyName, p.ProductName;

drop table if exists RankedCities;

select company, product, revenue, countCities,
    row_number() over (partition by company order by revenue desc) as rank
into RankedCities
from BestByCities
where countCities >= 20;

select company, product
from RankedCities
where rank = 1;

-- ex4 Dacă furnizorul a livrat produse către cel puțin 5 categorii distincte (CategoryID) (da sau nu).

drop table if exists DistinctCategories;

select s.CompanyName as company, count(distinct c.CategoryID) as countCat
into DistinctCategories
from Suppliers as s
    join Products as p on s.SupplierID = p.SupplierID
    join Categories as c on p.CategoryID = c.CategoryID
group by s.CompanyName;

select company,
    case
        when countCat >= 5
            then 'da'
            else 'nu'
    end as Cel_putin_5_categorii_distincte
from DistinctCategories;

-- ex5 Care este cel mai popular produs de la furnizor, cumpărat de clienții noi in mai multe tari

drop table if exists NewCustomers;
drop table if exists CountryAndSales;
drop table if exists RankedProductsForSuppliers;

select s.CompanyName, c.CustomerID, p.ProductName, o.ShipCountry
into NewCustomers
from Suppliers as s
    join Products as p on s.SupplierID = p.SupplierID
    join [Order Details] as od on p.ProductID = od.ProductID
    join Orders as o on od.OrderID = o.OrderID
    join Customers as c on o.CustomerID = c.CustomerID
group by s.CompanyName, c.CustomerID, p.ProductName, o.ShipCountry
having count(o.OrderID) = 1;

select *
from NewCustomers;

select
    nc.CompanyName,
    nc.ProductName,
    count(distinct nc.ShipCountry) as CountryCount,
    count(*) as TotalSales
into CountryAndSales
from NewCustomers nc
group by nc.CompanyName, nc.ProductName;

select
    cs.CompanyName,
    cs.ProductName,
    cs.CountryCount,
    cs.TotalSales,
    ROW_NUMBER() over (partition by cs.CompanyName order by cs.TotalSales desc) as Rank
into RankedProductsForSuppliers
from CountryAndSales cs
where cs.CountryCount > 1;

select
    CompanyName,
    ProductName,
    CountryCount,
    TotalSales
from RankedProductsForSuppliers
where Rank = 1;

-- marti nr 2
-- Pentru fiecare tara afișați:

-- Ex1: Categoria cu cele mai mari vânzări
drop table if exists Sales, RankedSales, SalesTarget, SuppliersWithDiscontinued, CountryRevenue, ProfitableCities;

-- Categoria cu cele mai mari vânzări
select s.Country, c.CategoryName, sum(od.Quantity * od.UnitPrice) as sales
into Sales
from Suppliers s
    join Products p on s.SupplierID = p.SupplierID
    join Categories c on p.CategoryID = c.CategoryID
    join [Order Details] od on p.ProductID = od.ProductID
group by s.Country, c.CategoryName;

select *, ROW_NUMBER() over (partition by Country order by sales desc) as rank
into RankedSales
from Sales;

-- Ex2: Determinarea țărilor "target" sau "normal"
select s.Country, sum(od.Quantity * od.UnitPrice) as sales
into SalesTarget
from Suppliers s
    join Products p on s.SupplierID = p.SupplierID
    join Categories c on p.CategoryID = c.CategoryID
    join [Order Details] od on p.ProductID = od.ProductID
group by s.Country;

declare @countryMean int;
select @countryMean = avg(sales)
from SalesTarget;

-- Ex3: Furnizorii care au livrat produse discontinue
select s.Country, s.CompanyName
into SuppliersWithDiscontinued
from Suppliers s
    join products p on s.SupplierID = p.SupplierID
    join categories c on p.CategoryID = c.CategoryID
where p.Discontinued = 1
group by s.Country, s.CompanyName
having count(c.CategoryID) >= 2;

-- Ex4: Venitul țării comparat cu media globală
select s.Country, sum(od.Quantity * od.UnitPrice) as revenue
into CountryRevenue
from Suppliers s
    join Products p on s.SupplierID = p.SupplierID
    join Categories c on p.CategoryID = c.CategoryID
    join [Order Details] od on p.ProductID = od.ProductID
group by s.Country;

declare @countryrevmean decimal(18,2);
select @countryrevmean = avg(revenue)
from CountryRevenue;

-- Ex5: Cea mai profitabilă locație de livrare (ProfitabileCities)
with
    ProfitsPerCity
    as
    (
        select o.ShipCountry as Country, o.ShipCity as City,
            count(o.OrderID) as delivery_count,
            sum(od.Quantity * od.UnitPrice) as Profit
        from Orders o
            join [Order Details] od on od.OrderID = o.OrderID
        group by o.ShipCountry, o.ShipCity
    ),
    NotSingleCities
    as
    (
        select Country
        from ProfitsPerCity
        group by Country
        having count(City) >= 2
    ),
    FilteredProfitsPerCity
    as
    (
        select ppc.Country, ppc.City, ppc.Profit
        from ProfitsPerCity ppc
            join NotSingleCities nsc on ppc.Country = nsc.Country
        where ppc.delivery_count >= 20
    ),
    RankedCities
    as
    (
        select Country, City, Profit,
            ROW_NUMBER() over (partition by Country order by Profit desc) as rank
        from FilteredProfitsPerCity
    )
select Country, City, Profit
into ProfitableCities
from RankedCities
where rank = 1;

-- Combinarea rezultatelor într-un singur tabel
select
    r.Country,
    r.CategoryName as MostSoldCategory,
    r.sales as CategorySales,
    case
        when st.sales > @countryMean then 'target'
        else 'normal'
    end as SalesStatus,
    sd.CompanyName as SupplierWithDiscontinuedProducts,
    case
        when cr.revenue > 1.2 * @countryrevmean then 'da'
        else 'nu'
    end as '>= 120% peste medie',
    pc.City as MostProfitableCity,
    pc.Profit as CityProfit
into FinalResults
from RankedSales r
    left join SalesTarget st on r.Country = st.Country
    left join SuppliersWithDiscontinued sd on r.Country = sd.Country
    left join CountryRevenue cr on r.Country = cr.Country
    left join ProfitableCities pc on r.Country = pc.Country
where r.rank = 1;

-- Afișarea tabelului final
select *
from FinalResults;
