   set SERVEROUTPUT on;

-- 1.⁠ ⁠(1p)Categoria cu cele mai mari vânzări(CategoryName).

with vanzari_categorii as (
      select s.country,
             p.categoryid,
             sum(od.quantity * od.unitprice) as vanzari
        from suppliers s
        join products p
      on s.supplierid = p.supplierid
        join order_details od
      on p.productid = od.productid
       group by s.country,
                p.categoryid
       order by country
)
select v1.country,
       v1.categoryid,
       c.CATEGORYNAME,
       v1.vanzari as max_vanzari
  from vanzari_categorii v1
  join categories c on v1.categoryid = c.CATEGORYID 
 where vanzari = (
   select max(v2.vanzari)
     from vanzari_categorii v2
    where v1.country = v2.country
)
order by country
;