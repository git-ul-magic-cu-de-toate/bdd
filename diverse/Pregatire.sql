USE northwind;
GO

-- ex 1
WITH
    Counts
    AS
    (
        SELECT s.CompanyName AS cname, p.ProductName AS pname, COUNT(*) count
        FROM Suppliers s
            JOIN Products p ON s.SupplierID = p.SupplierID
            JOIN [Order Details] od ON p.ProductID = od.ProductID
        GROUP BY s.CompanyName, p.ProductName
    ),
    Ranked
    AS
    (
        SELECT cname, pname, count,
            ROW_NUMBER() OVER (PARTITION BY cname ORDER BY count DESC) AS rank
        FROM Counts
    )
SELECT cname, pname
FROM Ranked
WHERE rank = 1;

-- ex 2
SELECT s.CompanyName, SUM(od.UnitPrice * od.Quantity) revenue
INTO SuppliersRevenue
FROM Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY s.CompanyName;

DECLARE @totalmean INT;
SELECT @totalmean = AVG(revenue)
FROM SuppliersRevenue;

SELECT CompanyName,
    CASE
        WHEN revenue > @totalmean THEN 'RELEVANT'
        ELSE 'MARGINAL'
    END AS tip
FROM SuppliersRevenue;

-- ex 3
WITH
    Profits
    AS
    (
        SELECT s.CompanyName AS cname, p.ProductName AS pname,
            SUM(od.Quantity * od.UnitPrice) profit, COUNT(DISTINCT o.ShipCity) citiesCount
        FROM Suppliers s
            JOIN Products p ON s.SupplierID = p.SupplierID
            JOIN [Order Details] od ON p.ProductID = od.ProductID
            JOIN Orders o ON od.OrderID = o.OrderID
        GROUP BY s.CompanyName, p.ProductName
    ),
    Ranked
    AS
    (
        SELECT cname, pname, profit, citiesCount,
            ROW_NUMBER() OVER (PARTITION BY cname ORDER BY profit DESC) AS rank
        FROM Profits
        WHERE citiesCount >= 20
    )
SELECT cname, pname
FROM Ranked
WHERE rank = 1;

-- ex 4
WITH
    CTE
    AS
    (
        SELECT s.CompanyName, COUNT(DISTINCT c.CategoryID) AS countCat
        FROM Suppliers s
            JOIN Products p ON s.SupplierID = p.SupplierID
            JOIN Categories c ON c.CategoryID = p.CategoryID
        GROUP BY s.CompanyName
    )
SELECT CompanyName, (CASE WHEN countCat >= 5 THEN 'da' ELSE 'nu' END) AS 'Cel putin 5 categorii'
FROM CTE;

-- ex 5
WITH
    NewCustomers
    AS
    (
        SELECT s.CompanyName, c.CustomerID, p.ProductName
        FROM Suppliers s
            JOIN Products p ON s.SupplierID = p.SupplierID
            JOIN [Order Details] od ON od.ProductID = p.ProductID
            JOIN Orders o ON o.OrderID = od.OrderID
            JOIN Customers c ON c.CustomerID = o.CustomerID
        GROUP BY s.CompanyName, c.CustomerID, p.ProductName
        HAVING COUNT(o.OrderID) = 1
    ),
    Counts
    AS
    (
        SELECT CompanyName, ProductName, COUNT(*) AS count
        FROM NewCustomers
        GROUP BY CompanyName, ProductName
    ),
    Ranked
    AS
    (
        SELECT CompanyName, ProductName,
            ROW_NUMBER() OVER (PARTITION BY CompanyName ORDER BY count) AS rank
        FROM Counts
    )
SELECT CompanyName, ProductName
FROM Ranked
WHERE rank = 1;

-- SUBIECTUL 2

-- ex 1
WITH
    Vanzari
    AS
    (
        SELECT s.Country, c.CategoryName, SUM(od.Quantity * od.UnitPrice) AS vanzari
        FROM Suppliers s
            JOIN Products p ON s.SupplierID = p.SupplierID
            JOIN Categories c ON p.CategoryID = c.CategoryID
            JOIN [Order Details] od ON od.ProductID = p.ProductID
        GROUP BY s.Country, c.CategoryName
    ),
    Ranked
    AS
    (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY Country ORDER BY vanzari DESC) AS rank
        FROM Vanzari
    )
SELECT Country, CategoryName
FROM Ranked
WHERE rank = 1;

-- ex 2
SELECT s.Country, SUM(od.UnitPrice * od.Quantity) revenue
INTO CountryRevenue
FROM Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY s.Country;

DECLARE @countryrevmean INT;

SELECT @countryrevmean = AVG(revenue)
FROM CountryRevenue;

SELECT Country,
    CASE
        WHEN revenue > @countryrevmean THEN 'TARGET'
        ELSE 'NORMAL'
    END AS isTarget
FROM CountryRevenue;

-- ex 3
SELECT s.Country, s.CompanyName
FROM Suppliers s
    JOIN Products p ON p.SupplierID = s.SupplierID
    JOIN Categories c ON c.CategoryID = p.CategoryID
WHERE p.Discontinued = 1
GROUP BY s.Country, s.CompanyName
HAVING COUNT(c.CategoryID) >= 2;

-- ex 4
SELECT Country,
    CASE
        WHEN revenue > 1.2 * @countryrevmean THEN 'da'
        ELSE 'nu'
    END AS '> 120% peste medie'
FROM CountryRevenue;


-- ex 5
WITH
    ProfitsPerCity
    AS
    (
        SELECT o.ShipCountry AS Country, o.ShipCity AS City,
            COUNT(o.OrderID) Count, SUM(od.Quantity * od.UnitPrice) Profit
        FROM Orders o
            JOIN [Order Details] od ON od.OrderID = o.OrderID
        GROUP BY o.ShipCountry, o.ShipCity
    ),
    NotSingleCities
    AS
    (
        SELECT Country
        FROM ProfitsPerCity
        GROUP BY Country
        HAVING COUNT(City) >= 2
    ),
    ProfitableCities
    AS
    (
        SELECT ppc.Country, City, Profit
        FROM ProfitsPerCity ppc
            JOIN NotSingleCities nsc ON ppc.Country = nsc.Country
        WHERE Count >= 20
    ),
    Ranked
    AS
    (
        SELECT Country, City, ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Profit DESC) AS rank
        FROM ProfitableCities
    )
SELECT Country, City
FROM Ranked
WHERE rank = 1;

