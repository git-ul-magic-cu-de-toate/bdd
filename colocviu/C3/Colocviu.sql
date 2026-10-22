USE northwind;
GO

-- Numarul 1

-- Exe 1
WITH CountOrders AS (
    SELECT s.CompanyName, o.ShipCity, COUNT(o.OrderID) AS Count
    FROM Suppliers s
    JOIN Products p ON s.SupplierID = p.ProductID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    GROUP BY s.CompanyName, o.ShipCity
), Ranked AS (
    SELECT CompanyName, ShipCity,
    ROW_NUMBER() OVER (PARTITION BY CompanyName ORDER BY Count DESC) AS rank
    FROM CountOrders
)
SELECT CompanyName, ShipCity
INTO Exe1
FROM Ranked
WHERE rank = 1;

-- Exe 2
WITH OrderDates AS (
    SELECT s.CompanyName, o.OrderID, o.OrderDate
    FROM Suppliers s
    JOIN Products p ON s.SupplierID = p.ProductID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
), Ranked AS (
    SELECT CompanyName, OrderID, OrderDate,
    ROW_NUMBER() OVER (PARTITION BY CompanyName ORDER BY OrderDate ASC) AS rank
    FROM OrderDates
)
SELECT CompanyName, OrderID, OrderDate
INTO Exe2
FROM Ranked
WHERE rank = 1;

-- Exe 3
DECLARE @mediepreturi FLOAT;

SELECT @mediepreturi = AVG(UnitPrice)
FROM Products;

SELECT s.CompanyName, STRING_AGG(ProductName, ', ') AS pr
INTO Exe3
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
WHERE p.UnitPrice > @mediepreturi
GROUP BY s.CompanyName;

-- Exe 4
WITH SuppliersCountRegions AS (
    SELECT s.CompanyName, COUNT(DISTINCT o.ShipRegion) AS Count
    FROM Suppliers s
    JOIN Products p ON s.SupplierID = p.ProductID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    GROUP BY s.CompanyName
)
SELECT CompanyName, CASE 
    WHEN Count >= 10 THEN 'Da'  
    ELSE 'Nu'
END AS danu
INTO Exe4
FROM SuppliersCountRegions;

-- Exe 5
DECLARE @numCountries INT;
SELECT @numCountries = COUNT(DISTINCT ShipCountry) FROM Orders;

WITH SoldInHalfCountries AS (
    SELECT s.SupplierID, s.CompanyName, c.CategoryID, c.CategoryName, SUM(od.Quantity * od.UnitPrice) AS Revenue
    FROM Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
    JOIN Categories c ON p.CategoryID = c.CategoryID
    JOIN [Order Details] od ON p.ProductID = od.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    GROUP BY s.SupplierID, s.CompanyName, c.CategoryID, c.CategoryName
    HAVING COUNT(DISTINCT o.ShipCountry) > @numCountries / 2
), SoldRanked AS (
    SELECT SupplierID, CompanyName, CategoryID, CategoryName, 
    ROW_NUMBER() OVER (PARTITION BY CompanyName ORDER BY Revenue DESC) AS rank
    FROM SoldInHalfCountries
), MostSold AS (
    SELECT SupplierID, CompanyName, CategoryID, CategoryName FROM SoldRanked WHERE rank = 1
), MostSoldProducts AS (
    SELECT ms.SupplierID, ms.CompanyName, ms.CategoryID, ms.CategoryName, p.ProductName, COUNT(o.OrderID) AS NumOrders
    FROM MostSold ms
    JOIN Products p ON p.SupplierID = ms.SupplierID AND p.CategoryID = ms.CategoryID
    JOIN [Order Details] od ON od.ProductID = p.ProductID
    JOIN Orders o ON o.OrderID = od.OrderID
    GROUP BY ms.SupplierID, ms.CompanyName, ms.CategoryID, ms.CategoryName, p.ProductName
), Ranked AS (
    SELECT CompanyName, CategoryName, ProductName,
    ROW_NUMBER() OVER (PARTITION BY SupplierID, CompanyName, CategoryID, CategoryName ORDER BY NumOrders DESC) AS rank
    FROM MostSoldProducts
)
SELECT CompanyName, 
       CategoryName, 
       ProductName
INTO Exe5
FROM Ranked
WHERE rank = 1;


-- combinate

SELECT 
e1.CompanyName, 
e1.ShipCity AS 'Orasul cu cele mai multe comenzi',
e2.OrderID AS 'Cea mai veche comanda',
e2.OrderDate AS 'Data cea mai veche comanda',
e3.pr AS 'Produse cu pret peste medie',
e4.danu AS 'A livrat in cel putin 10 regiuni',
e5.CategoryName AS 'Categoria cea mai vanduta in peste 50% din tari',
e5.ProductName AS 'Produsul cel mai vandut din aceasta categorie'
FROM Exe1 e1
JOIN Exe2 e2 ON e1.CompanyName = e2.CompanyName
JOIN Exe3 e3 ON e1.CompanyName = e3.CompanyName AND e2.CompanyName = e3.CompanyName
JOIN Exe4 e4 ON e1.CompanyName = e4.CompanyName AND e2.CompanyName = e3.CompanyName 
                                AND e3.CompanyName = e4.CompanyName
JOIN Exe5 e5 ON e1.CompanyName = e5.CompanyName AND e2.CompanyName = e5.CompanyName 
                                AND e3.CompanyName = e5.CompanyName AND e4.CompanyName = e5.CompanyName;

SELECT * FROM Exe1;
SELECT * FROM Exe2;
SELECT * FROM Exe3;
SELECT * FROM Exe4;