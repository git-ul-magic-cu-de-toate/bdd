   set SERVEROUTPUT on;


-- 3.  ⁠(2p) Produsul cel mai bine vândut (ProductName) pentru fiecare 
-- furnizor, dar doar dacă produsul a fost comandat în cel puțin 20 locații distincte (ShipCity).

with orase_produs as (
   select s.supplierid,
          p.productid,
          o.shipcity
     from suppliers s
     join products p
   on s.supplierid = p.supplierid
     join order_details od
   on od.productid = p.productid
     join orders o
   on o.orderid = od.orderid
),nr_orase_per_produs as (
   select supplierid,
          productid,
          count(distinct shipcity) as nr_orase_distincte
     from orase_produs
    group by supplierid,
             productid
),calc_quant as (
   select s.supplierid,
          s.companyname,
          p.productname,
          p.productid,
          sum(od.quantity) as quant
     from suppliers s
     join products p
   on s.supplierid = p.supplierid
     join order_details od
   on p.productid = od.productid
    group by s.supplierid,
             s.companyname,
             p.productname,
             p.productid
)
select supplierid,
       companyname,
       productname,
       quant
  from calc_quant cq
 where quant = (
      select max(quant)
        from calc_quant
       where supplierid = cq.supplierid
   )
   and (
   select nr_orase_distincte
     from nr_orase_per_produs
    where productid = cq.productid
) >= 20
 order by supplierid;


-- // mihai

with aux as (
   select s.supplierid,
          s.companyname,
          p.productname,
          sum(od.quantity) as quant
     from suppliers s
     join products p
   on s.supplierid = p.supplierid
     join order_details od
   on p.productid = od.productid
     join (
      select supplierid,
             companyname,
             productname,
             no_city
        from (
         select s.supplierid,
                s.companyname,
                p.productname,
                count(distinct o.shipcity) no_city
           from suppliers s
           join products p
         on s.supplierid = p.supplierid
           join order_details od
         on p.productid = od.productid
           join orders o
         on od.orderid = o.orderid
          group by s.supplierid,
                   s.companyname,
                   p.productname
          order by s.supplierid
      )
       where no_city > 20
   ) aux
   on s.supplierid = aux.supplierid
      and p.productname = aux.productname
    group by s.supplierid,
             s.companyname,
             p.productname
    order by s.supplierid
)
select supplierid,
       companyname,
       productname,
       quant
  from aux au
 where quant = (
   select max(quant)
     from aux
    where supplierid = au.supplierid
);

-- // 3, 9, 22, 27