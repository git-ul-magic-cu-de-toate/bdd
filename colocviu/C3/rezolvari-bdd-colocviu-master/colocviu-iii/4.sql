-- 4.⁠ ⁠(2p)Daca valoarea totală a comenzilor depășește cu cel puțin 20% valoarea medie globală a comenzilor. ( “da” sau “nu”) 

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

select country, vanzari as total_vanzari, 
case when vanzari > (select ROUND(AVG(vanzari), 2) / 5 from total_vanzari_tari) then 'da' else 'nu' end as status,
(select ROUND(AVG(vanzari), 2) / 5 from total_vanzari_tari) as medie
from total_vanzari_tari;
