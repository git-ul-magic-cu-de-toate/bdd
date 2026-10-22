--  Să se declare un cursor care selectează denumirea departamentului, numele angajatului, 
-- salariul și data angajării pentru acei angajati care au venit în companie în 2003.

   set SERVEROUTPUT on;

declare
   cursor c_angajati is
   select d.department_name,
          e.first_name
          || ' '
          || e.last_name as name,
          e.salary,
          e.hire_date
     from employees e
     join departments d
   on e.department_id = d.department_id
    where extract(year from e.hire_date) = 2003
    order by hire_date;

   cursor_line c_angajati%rowtype;
begin
   open c_angajati;
   loop
      fetch c_angajati into cursor_line;
      exit when c_angajati%notfound;
      dbms_output.put_line(cursor_line.department_name
                           || ' '
                           || cursor_line.name
                           || ' '
                           || cursor_line.salary
                           || ' '
                           || cursor_line.hire_date);
   end loop;

   close c_angajati;
end;