   set SERVEROUTPUT on;

-- 3. Produsele (ProductName) cu pretul peste media preturilor tuturor produselor din baza de date. (2p)

    SELECT s.supplierid, p.productName, p.unitprice
    FROM SUPPLIERS s join PRODUCTS p
    on s.SUPPLIERID = p.SUPPLIERID
    WHERE p.UNITPRICE > (select round(
      avg(unitprice),
      2
   )
     from products);