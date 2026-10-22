-- 2.  ⁠(2p) Dacă furnizorul este "relevant" sau "marginal": 
-- Un furnizor este "relevant" dacă valoarea totală a produselor (OrderDetails.Quantity *OrderDetails.UnitPrice
-- ) livrate depășește media globală a vânzărilor pe furnizori.

with medii_produse as (
   select s.supplierid,
          sum(od.quantity + od.unitprice) as suma_vanzari
     from suppliers s
     join products p
   on s.supplierid = p.supplierid
     join order_details od
   on p.productid = od.productid
    group by s.supplierid,
             p.productid
),medii_furnizori as (
   select supplierid,
          round(
             avg(suma_vanzari),
             2
          ) as medie
     from medii_produse
    group by supplierid
),average_medie as (
   select avg(medie) as avg_medie
     from medii_furnizori
)
select mf.supplierid,
       mf.medie,
       case
          when mf.medie > (
             select am.avg_medie
               from average_medie am
          ) then
             'relevant'
          else
             'marginal'
       end as tip_furnizor
  from medii_furnizori mf
 order by supplierid;