/*
Sa se scrie un bloc PL/SQL care printeaza angajatii care detin venitul maxim
din fiecare departament sau detin un salariu peste media job-ului
lor cu cel putin 15%. Sa se poata face distinctia intre ei.
*/

   SET SERVEROUTPUT ON;

DECLARE
    -- Define a record type to store a single employee's data
    TYPE custom_employee_entry IS RECORD (
        nume     VARCHAR2(200),
        criteriu VARCHAR2(50),
        salariu  NUMBER
    );

    -- Define a collection type for the record
    TYPE tabel_employees IS TABLE OF custom_employee_entry;

    -- Declare a collection variable
    emp_table tabel_employees;

BEGIN
    -- Fetch data into the collection using BULK COLLECT
    SELECT e.first_name || ' ' || e.last_name AS nume,
           'Salariu maxim in departament' AS criteriu,
           e.salary + NVL(e.commission_pct, 0)* e.salary AS salariu
    BULK COLLECT INTO emp_table
    FROM employees e
    WHERE e.salary + NVL(e.commission_pct, 0)* e.salary = (
              SELECT MAX(salary + NVL(commission_pct * salary, 0))
              FROM employees
              WHERE department_id = e.department_id
          )
    UNION ALL
    SELECT e.first_name || ' ' || e.last_name AS nume,
           'Salariu peste media job-ului' AS criteriu,
           e.salary + NVL(e.commission_pct, 0)* e.salary AS salariu
    FROM employees e
    WHERE e.salary + NVL(e.commission_pct, 0)* e.salary > (
              SELECT AVG(salary + NVL(commission_pct * salary, 0)) * 1.15
              FROM employees
              WHERE job_id = e.job_id
          );

    -- Iterate over the collection and print results
    FOR i IN emp_table.FIRST .. emp_table.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(emp_table(i).nume || ' | ' || emp_table(i).criteriu || ' | ' || emp_table(i).salariu);
    END LOOP;
END;
/
