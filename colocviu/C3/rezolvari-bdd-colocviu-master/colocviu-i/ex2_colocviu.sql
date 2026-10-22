SET SERVEROUTPUT ON;

-- // 2. Cea mai veche comanda (OrderID & data) (1p)

SELECT s.supplierid,
       o.orderid,
       o.orderdate
  FROM suppliers s
  JOIN products p
    ON s.supplierid = p.supplierid
  JOIN order_details od
    ON p.productid = od.productid
  JOIN orders o
    ON od.orderid = o.orderid
WHERE months_between(sysdate, o.orderdate) = (
    SELECT max(months_between(sysdate, o2.orderdate))
      FROM suppliers s2
      JOIN products p2
        ON s2.supplierid = p2.supplierid
      JOIN order_details od2
        ON p2.productid = od2.productid
      JOIN orders o2
        ON od2.orderid = o2.orderid
     WHERE s2.supplierid = s.supplierid
);
