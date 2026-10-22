-- Să se scrie o procedură nestocată, care utilizează un cursor, pentru calculul numărului de zile de concediu pentru toți angajații, 
-- după următorul algoritm:

-- manageri de departament:
-- Vechimea < 13 de ani primesc 20 zile de concediu
-- Vechimea >= 13 de ani primesc 22 zile de concediu
-- angajații care nu sunt șefi:
-- Vechimea < 13 de ani primesc 15 zile de concediu
-- Vechimea >= 13 de ani primesc 22 zile de concediu

   set SERVEROUTPUT on;

declare
   procedure zile_concediu is
      cursor c_concediu is
      select *
        from employees
       where department_id is not null
       order by department_id;

      randconcediu c_concediu%rowtype;
      manager      employees.manager_id%type;
      type r_concediu is record (
            nume         varchar2(50),
            nume_dept    departments.department_name%type,
            dataang      employees.hire_date%type,
            sef          varchar2(2),
            anivechime   number,
            zileconcediu number
      );
      concediu     r_concediu;
   begin
      open c_concediu;
      loop
         fetch c_concediu into randconcediu;
         exit when c_concediu%notfound;
         select department_name
           into concediu.nume_dept
           from departments
          where department_id = randconcediu.department_id;

         concediu.dataang := randconcediu.hire_date;
         concediu.nume := randconcediu.first_name
                          || ' '
                          || randconcediu.last_name;
         concediu.anivechime := trunc(months_between(
            sysdate,
            randconcediu.hire_date
         ) / 12);

         begin
            select manager_id
              into manager
              from employees
             where manager_id = randconcediu.employee_id;

            concediu.sef := 'DA';
         exception
            when no_data_found then
               concediu.sef := 'NU';
            when too_many_rows then
               concediu.sef := 'DA';
         end;

         if
            concediu.anivechime < 13
            and concediu.sef = 'DA'
         then
            concediu.zileconcediu := 20;
         elsif concediu.anivechime >= 13 then
            concediu.zileconcediu := 22;
         elsif
            concediu.anivechime < 13
            and concediu.sef = 'NU'
         then
            concediu.zileconcediu := 15;
         end if;

         dbms_output.put_line(concediu.nume_dept
                              || ' '
                              || concediu.nume
                              || ' '
                              || concediu.dataang
                              || ' '
                              || concediu.sef
                              || ' '
                              || concediu.anivechime
                              || ' '
                              || concediu.zileconcediu);

      end loop;

   end zile_concediu;
begin
   zile_concediu;
end;