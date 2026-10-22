-- 3.⁠ ⁠(2p)Furnizorii care au livrat produse discontinue (Products.Discontinued = 1) din cel puțin 2 categorii diferite. 


select COUNTRY, SUPPLIERID, COMPANYNAME, nr_categorii
from
(SELECT s.COUNTRY, s.SUPPLIERID, s.COMPANYNAME, count(distinct c.CATEGORYNAME) as nr_categorii
from suppliers s join products p on s.supplierid = p.supplierid
join categories c on p.CATEGORYID = c.CATEGORYID
where p.DISCONTINUED = 1
group by s.COUNTRY, s.SUPPLIERID, s.COMPANYNAME)
where nr_categorii >= 2;