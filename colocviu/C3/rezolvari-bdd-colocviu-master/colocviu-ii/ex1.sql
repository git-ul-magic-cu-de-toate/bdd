   set SERVEROUTPUT on;
-- .  (1p) Care este produsul cel mai vândut

with calc_quant as (
   select s.supplierid,
          s.companyname,
          p.productname,
          sum(od.quantity) as quant
     from suppliers s
     join products p
   on s.supplierid = p.supplierid
     join order_details od
   on p.productid = od.productid
    group by s.supplierid,
             s.companyname,
             p.productname
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
 order by supplierid;