   set SERVEROUTPUT on;

-- 1. Orașul cu cele mai multe comenzi (1p)

select s.companyname as suppliername,
       o.shipcity,
       count(o.orderid) as ordercount
  from suppliers s
  join products p
on s.supplierid = p.supplierid
  join order_details od
on p.productid = od.productid
  join orders o
on od.orderid = o.orderid
 group by s.supplierid,
          s.companyname,
          o.shipcity
having count(o.orderid) = (
   select max(count(o2.orderid))
     from orders o2
     join order_details od2
   on o2.orderid = od2.orderid
     join products p2
   on od2.productid = p2.productid
    where p2.supplierid = s.supplierid
    group by o2.shipcity
);