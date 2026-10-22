use northwind;
go

-- NR 2.

-- Sa se afiseze pentru fiecare angajat:

-- - [1p] Categoria de produse pentru care a inregistrat cele mai multe vanzari (cantitativ)

-- - [2p] Cea mai mare crestere procentuala in vanzari pe care a inregistrat-o de la o luna la alta, indiferent de produs, in anul in care s a angajat

-- - [2p] Numarul de ani in care numarul de comenzi procesate de el este mai mare decat media numarului de comenzi pentru ceilalti angajati in acelasi an

-- - [2p] Cea mai lunga perioada consecutiva (in luni) din anul in care s a angajat in care numarul total de produse vandute de el a fost mai mare decat media produselor vandute de toti angajatii in luna respectiva

-- - [3p] Daca nivelul unui angajat influenteaza valoarea incasarilor totale realizate de acesta

--     - Nivelul se calculeaza astfel:

--         - daca este in companie de 5 ani sau mai putin, nivelul este "Junior"

--         - daca este in companie de 6-10 ani, nivelul este "Mid"

--         - daca este in companie de mai mult de 10 ani, nivelul este "Senior"

--     - Daca un angajat dintr-o perioada X se afla in top 75% al incasarilor totale (OrderDetails.Discount * OrderDetails.Quantity * OrderDetails.UnitPrice) realizate de angajatii din perioada imediat inferioara, se afiseaza "DA", altfel "NU"

--     - Pentru angajatii "Junior", se afiseaza "-"



-- [1p] Afisati rezultatele sub forma unui singur tabel

drop table if exists Sales, RankedSales, Procent, RankedProcent, Count, RankedCount, FinalResults;

-- ex1 Categoria de produse pentru care a inregistrat cele mai multe vanzari (cantitativ)
select e.EmployeeID as angajat, c.CategoryName as categorie, sum(od.Quantity) as sales
into Sales
from Employees e
    join Orders o on e.EmployeeID = o.EmployeeID
    join [Order Details] od on o.OrderID = od.OrderID
    join Products p on od.ProductID = p.ProductID
    join Categories c on p.CategoryID = c.CategoryID
group by e.EmployeeID, c.CategoryName;

select *, ROW_NUMBER() over (partition by angajat order by sales desc) as rank
into RankedSales
from Sales;

-- ex2 Cea mai mare crestere procentuala in vanzari pe care a inregistrat-o de la o luna la alta, indiferent de produs, in anul in care s a angajat

select e.EmployeeID angajat, YEAR(e.HireDate) as year, MONTH(o.OrderDate) month, sum(od.Discount * od.Quantity * od.UnitPrice) as procent
into Procent
from Employees e
    join Orders o on e.EmployeeID = o.EmployeeID
    join [Order Details] od on o.OrderID = od.OrderID
group by e.EmployeeID, e.HireDate, o.OrderDate

select *, ROW_NUMBER() over (partition by angajat order by procent desc) as rank
into RankedProcent
from Procent

-- ex3 Numarul de ani in care numarul de comenzi procesate de el este mai mare decat media numarului de comenzi pentru ceilalti angajati in acelasi an

select e.EmployeeID angajat, YEAR(o.OrderDate) hireYear, COUNT(o.OrderID) count
-- into Count
from Employees e
    join Orders o on e.EmployeeID = o.EmployeeID
    join [Order Details] od on o.OrderID = od.OrderID
group by e.EmployeeID, o.OrderDate;

select *
into RankedCount
from Procent
-- where count >

-- ex4 Cea mai lunga perioada consecutiva (in luni) din anul in care s a angajat in care numarul total de produse vandute de el a fost mai mare decat media produselor vandute de toti angajatii in luna respectiva

select e.EmployeeID angajat, YEAR(e.HireDate) hireYear, COUNT(o.orderID) count
-- into ConsecutiveMonths
from Employees e
    join Orders o on e.EmployeeID = o.EmployeeID
    join [Order Details] od on o.OrderID = od.OrderID
group by e.EmployeeID, e.HireDate;

-- afisare

select rs.angajat, rs.categorie, rp.procent
into FinalResults
from RankedSales rs
    left join RankedProcent rp on rs.angajat = rp.angajat
where rs.rank = 1 and rp.rank = 1;

select *
from FinalResults;