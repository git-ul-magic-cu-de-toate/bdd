SELECT e.firstname || ' ' || e.lastname as nume, e.EMPLOYEEID, 
    CASE
        when e.notes like '%Ph.D%' then 'Doctorat'
        when e.notes like '%MA%' or e.notes like '%MBA%' then 'Master'
        when e.notes like '%BA%' or e.notes like '%BS%' or e.notes like '%BSC%' then 'Licenta'
        else 'Lipsa informatii'
    end as studii
from employees e;