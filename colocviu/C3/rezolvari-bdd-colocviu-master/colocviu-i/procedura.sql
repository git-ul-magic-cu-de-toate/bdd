   SET SERVEROUTPUT ON;

declare
   nume_dept departments.department_name%type;
   iddept    employees.department_id%type := '&id_dept';

   procedure sal_max (
      id_dept       in number,
      func          in out varchar2,
      salariu_maxim out number
   ) is
      salmax number;
   begin
      select max(salary)
        into salmax
        from employees
       where department_id = id_dept
         and lower(job_id) = lower(func)
       group by department_id;

      salariu_maxim := salmax;
      func :=
         case
            when ( upper(func) = 'FI_ACCOUNT' ) then
               'Contabil'
            when ( upper(func) = 'IT_PROG' ) then
               'Programator'
            when ( upper(func) like '%_CLERK' ) then
               'Functionar'
            when ( upper(func) = 'AD_PRES' ) then
               'Presedinte'
            when ( upper(func) like '%_MAN' ) then
               'Manager'
            else 'Nu avem functie'
         end;
   exception
      when no_data_found then
         dbms_output.put_line('Nu s-a gasit nimic');
   end sal_max;

begin
   declare
      functie varchar2(40) := '&numeFunctie';
      salmax  number;
   begin
      select department_name
        into nume_dept
        from departments
       where department_id = iddept;

      sal_max(
         iddept,
         functie,
         salmax
      );
      dbms_output.put_line('In depart '
                           || nume_dept
                           || ' cu id '
                           || iddept
                           || ' salariu maxim este '
                           || salmax);
   exception
      when no_data_found then
         dbms_output.put_line('Depart inexistent');
   end;
end;
/
-- Reset substitution variables outside the PL/SQL block
UNDEFINE id_dept;      
UNDEFINE numeFunctie;