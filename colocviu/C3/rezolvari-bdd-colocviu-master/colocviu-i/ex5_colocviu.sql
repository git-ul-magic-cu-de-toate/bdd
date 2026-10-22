   set SERVEROUTPUT on;

-- 5. Categoria de produse (CategoryName) care este cea mai vanduta (Quantity * UnitPrice) in peste 50 % din tari si cel mai vandut produs asociat acestei categorii (3p)



-- DECLARE
--     category categories.CATEGORYNAME%TYPE;

-- begin
    -- select s.supplierid, c.CATEGORYNAME as cea_mai_vanduta_categorie
    -- -- into category
    -- from suppliers s join products p on s.SUPPLIERID = p.SUPPLIERID join CATEGORIES c on p.CATEGORYID = c.CATEGORYID
    -- where c.CATEGORYNAME = 
    --     (
    --         select c2.CATEGORYNAME
    --         from suppliers s2 join products p2 on s2.SUPPLIERID = p2.SUPPLIERID 
    --         join CATEGORIES c2 on p2.CATEGORYID = c2.CATEGORYID
    --         where s2.SUPPLIERID = s.supplierid
    --         group by c2.CATEGORYID
    --         HAVING SUM(p2.QUANTITYPERUNIT * p2.UNITPRICE) = 
    --                 (
    --                     SELECT MAX(SUM(p3.QUANTITYPERUNIT * p3.UNITPRICE)) 
    --                     from suppliers s3 join products p3 on s3.SUPPLIERID = p3.SUPPLIERID 
    --                     join CATEGORIES c3 on p3.CATEGORYID = c3.CATEGORYID
    --                     where s3.SUPPLIERID = s2.supplierid
    --                     group by c3.CATEGORYID 
    --                 )
                
    --         );

-- select distinct s.supplierid,
--        c.categoryname as cea_mai_vanduta_categorie
--   from suppliers s
--   join products p
-- on s.supplierid = p.supplierid
--   join categories c
-- on p.categoryid = c.categoryid
--  where c.categoryid = (
--    select c2.categoryid
--      from products p2
--      join categories c2
--    on p2.categoryid = c2.categoryid
--     where p2.supplierid = s.supplierid
--     group by c2.categoryid
--     order by sum(p2.unitsonorder * p2.unitprice) desc
--     fetch first 1 row only
-- );

select p.productname,
       c.categoryname,
       c.categoryid,
       p.unitsonorder * p.unitprice as vanzari
  from products p
  join categories c
on p.categoryid = c.categoryid
 where p.unitsonorder * p.unitprice = (
   select max(p2.unitsonorder * p2.unitprice)
     from products p2
     join categories c2
   on p2.categoryid = c2.categoryid
    where c2.categoryid = c.categoryid
    group by c2.categoryid
);



--  group by c.categoryid;
--  order by supplierid;