   set SERVEROUTPUT on;

-- 2.⁠ ⁠(2p)Daca este tara target afișați “target”, altfel afișați “normal” ( o tara este target daca valoarea 
-- totală a comenzilor OrderDetails.Quantity *OrderDetails.UnitPrice) depășește media valorii comenzilor pe toate țările) 

    with total_vanzari_tari as (
      select s.country,
             sum(od.quantity * od.unitprice) as vanzari
        from suppliers s
        join products p
      on s.supplierid = p.supplierid
        join order_details od
      on p.productid = od.productid
       group by s.country
       order by country
    )

-- select ROUND(AVG(vanzari), 2) from total_vanzari_tari;

select country, vanzari as total_vanzari, 
case when vanzari > (select ROUND(AVG(vanzari), 2) from total_vanzari_tari) then 'target' else 'normal' end as status,
(select ROUND(AVG(vanzari), 2) from total_vanzari_tari) as medie
from total_vanzari_tari;