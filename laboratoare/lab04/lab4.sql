-- set SERVEROUTPUT ON;


-- DECLARE
--     CURSOR c_angajati IS
--         SELECT d.department_name, e.employee_id, e.first_name || ' ' || e.last_name AS name, e.salary, e.commission_pct
--         FROM employees e INNER JOIN departments d ON e.department_id = d.DEPARTMENT_ID
--         WHERE
--             upper(e.JOB_ID) LIKE '%MGR' OR
--             upper(e.JOB_ID) LIKE '%MAN' OR
--             upper(e.JOB_ID) LIKE '%PRES';
--         angajat c_angajati%ROWTYPE;
--         venit NUMBER := 0;
-- BEGIN
--     OPEN c_angajati;
    
--     DBMS_OUTPUT.PUT_LINE(rpad('ECUSON', 10) || rpad('NUME', 30) || rpad('DEPARTAMENT', 20) || lpad('VENIT', 10));
--     DBMS_OUTPUT.PUT_LINE(rpad('=', 10, '=') || rpad('=', 30, '=') || rpad('=', 20, '=') || lpad('=', 10, '='));
        
--         LOOP
--             FETCH c_angajati INTO angajat;
--             EXIT WHEN c_angajati%NOTFOUND;
            
--             venit := round(angajat.salary + nvl(angajat.commission_pct, 0) * angajat.salary);
            
--             DBMS_OUTPUT.PUT_LINE(rpad(angajat.employee_id, 10)
--                 || rpad(angajat.name, 30) || rpad(angajat.department_name, 20) || lpad(venit, 10));
--         END LOOP;
--     CLOSE c_angajati;
    
-- END;

-- Actualizati și afișați angajații după următoarele criterii: 
-- -Pentru angajații care au salariul minim din departamentul, o mărire de 7.5%
-- -Pentru angajații care au salariul maxim din departament o mărire de 5%
-- -Pentru angajații care au salariu mai mic decât media salariului departamentului, o mărire de 10%
-- -Pentru angajații care au schimbat mai multe de doua job uri, o mărire de 5% din media salariului primului job.
-- Măririle sunt cumulativ
-- Sa se afișeze numele angajatului, job ul, salariul inițial, criteriul/criteriile de mărire, salariul final

set SERVEROUTPUT ON;

DECLARE
    TYPE salary_stats IS RECORD (
        min_salary NUMBER,
        max_salary NUMBER,
        avg_salary NUMBER
    );
    
    TYPE salary_stats_table IS TABLE OF salary_stats INDEX BY PLS_INTEGER;
    
    CURSOR c_departments IS
        SELECT department_id FROM departments;
    
    CURSOR c_angajati IS
        SELECT d.department_name, e.employee_id, e.first_name || ' ' || e.last_name AS name, e.salary, e.job_id, e.department_id
        FROM employees e INNER JOIN departments d ON e.department_id = d.DEPARTMENT_ID;
    
    angajat c_angajati%ROWTYPE;
    salariu_primul_job NUMBER;
    nr_joburi NUMBER;
    salariu_final NUMBER;
    department_salaries salary_stats_table;
    dept_id departments.department_id%TYPE;
    stats salary_stats;

BEGIN
    -- Populate the salary statistics table
    OPEN c_departments;
    LOOP
        FETCH c_departments INTO dept_id;
        EXIT WHEN c_departments%NOTFOUND;
        
        SELECT min(salary), max(salary), avg(salary)
        INTO stats.min_salary, stats.max_salary, stats.avg_salary
        FROM employees
        WHERE department_id = dept_id;
        
        department_salaries(dept_id) := stats;
    END LOOP;
    CLOSE c_departments;

    OPEN c_angajati;
    
    DBMS_OUTPUT.PUT_LINE(rpad('NUME', 30) || rpad('JOB', 20) || rpad('SALARIU INIȚIAL', 20) || rpad('CRITERIU', 20) || rpad('SALARIU FINAL', 20));
    DBMS_OUTPUT.PUT_LINE(rpad('=', 30, '=') || rpad('=', 20, '=') || lpad('=', 20, '=') || rpad('=', 20, '=') || lpad('=', 20, '='));
        
    LOOP
        FETCH c_angajati INTO angajat;
        EXIT WHEN c_angajati%NOTFOUND;
        
        stats := department_salaries(angajat.department_id);
        
        SELECT salary INTO salariu_primul_job FROM employees WHERE employee_id = angajat.employee_id AND rownum = 1;
        SELECT count(*) INTO nr_joburi FROM job_history WHERE employee_id = angajat.employee_id;
        
        salariu_final := angajat.salary;
        
        IF angajat.salary = stats.min_salary THEN
            salariu_final := salariu_final + salariu_final * 0.075;
            DBMS_OUTPUT.PUT_LINE(rpad(angajat.name, 30) ||
                                    rpad(angajat.job_id, 20) ||
                                    rpad(angajat.salary, 20) ||
                                    rpad('SALARIUL MINIM', 20) ||
                                    rpad(salariu_final, 20));
        ELSIF angajat.salary = stats.max_salary THEN
            salariu_final := salariu_final + salariu_final * 0.05;
            DBMS_OUTPUT.PUT_LINE(rpad(angajat.name, 30) ||
                                    rpad(angajat.job_id, 20) ||
                                    rpad(angajat.salary, 20) ||
                                    rpad('SALARIUL MAXIM', 20) ||
                                    rpad(salariu_final, 20));
        ELSIF angajat.salary < stats.avg_salary THEN
            salariu_final := salariu_final + salariu_final * 0.1;
            DBMS_OUTPUT.PUT_LINE(rpad(angajat.name, 30) ||
                                    rpad(angajat.job_id, 20) ||
                                    rpad(angajat.salary, 20) ||
                                    rpad('SALARIUL MEDIU', 20) ||
                                    rpad(salariu_final, 20));
        END IF;

        IF nr_joburi > 2 THEN
            salariu_final := salariu_final + salariu_primul_job * 0.05;
            DBMS_OUTPUT.PUT_LINE(rpad(angajat.name, 30) ||
                                    rpad(angajat.job_id, 20) ||
                                    rpad(angajat.salary, 20) ||
                                    rpad('MAI MULTE DE 2 JOBURI', 20) ||
                                    rpad(salariu_final, 20));
        END IF;

    END LOOP;
    CLOSE c_angajati;

END;