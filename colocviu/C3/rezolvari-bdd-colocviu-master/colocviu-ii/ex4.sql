   set SERVEROUTPUT on;

-- 4.  ⁠(2p) Dacă furnizorul a livrat produse către cel puțin 5 categorii distincte (CategoryID) (da sau nu).

select supplierid,
       case
          when nr_categorii >= 5 then
             'DA'
          else
             'NU'
       end as mai_mult_de_cinci_cat
  from (
   select s.supplierid,
          count(distinct p.categoryid) as nr_categorii
     from suppliers s
     join products p
   on s.supplierid = p.supplierid
    group by s.supplierid
    order by supplierid
);

-- // mihai

select s.supplierid,
       s.companyname,
       case
          when count(distinct p.categoryid) >= 5 then
             'DA'
          else
             'NU'
       end
  from suppliers s
  join products p
on s.supplierid = p.supplierid
 group by s.supplierid,
          s.companyname;