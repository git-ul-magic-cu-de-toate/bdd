-- Să se scrie o funcție stocată, f_puncte, care calculează numărul de puncte acumulate de angajați în vederea numirii unui șef pe fiecare departament.
-- Criteriile de punctaj și punctele aferente sunt următoarele:
-- 1. vechimea în firmă
--  - Ani vechime > 32 ⇒ 30 puncte
--  - Ani vechime <= 32 ⇒ 15 puncte
-- 2. salariul maxim pe departament
--  - Salariu angajat = salariu maxim din departament ⇒ 20 puncte
--  - Salariu angajat < salariu maxim din departament ⇒ 10 puncte
-- 3. comision
--  - Comision angajat > 0 ⇒ 10 puncte
--  - Comision angajat = 0 ⇒ 5 puncte
--  - Pentru stocarea punctelor acumulate de fiecare angajat, se va crea o tabelă temp_puncte care are următoarele coloane: idAng, nrPuncte, idDept.

-- CREATE TABLE temp_puncte (
--     idAng NUMBER,
--     nrPuncte NUMBER,
--     idDept NUMBER
-- );

-- CREATE OR REPLACE FUNCTION F_puncte(p_idang IN NUMBER)
-- RETURN NUMBER
-- IS
--     dataang employees.hire_date%TYPE;
--     iddept departments.department_id%TYPE;
--     salariu employees.salary%TYPE;
--     comision employees.commission_pct%TYPE;
--     salmax NUMBER;
--     puncte NUMBER := 0;
-- BEGIN
--     -- iau info de care am nevoie
--     SELECT hire_date, department_id, salary, nvl(commission_pct, 0)
--     INTO dataang, iddept, salariu, comision
--     FROM employees
--     WHERE employee_id = p_idang;

--     -- calculez puncte pentru vechime
--     IF Months_between(SYSDATE, dataang) > 32 * 12 THEN
--         puncte := puncte + 30;
--     ELSE
--         puncte := puncte + 15;
--     END IF;

--     -- calculez salariul maxim pe departament
--     SELECT max(salary)
--     INTO salmax
--     FROM employees
--     WHERE department_id = iddept;

--     -- calculez puncte pentru salariu
--     IF salariu = salmax THEN
--         puncte := puncte + 20;
--     ELSE
--         puncte := puncte + 10;
--     END IF;

--     -- calculez puncte pentru comision
--     IF comision > 0 THEN
--         puncte := puncte + 10;
--     ELSE
--         puncte := puncte + 5;
--     END IF;

--     RETURN puncte;
-- END f_puncte;

-- /
-- DECLARE
--     puncte NUMBER;
--     CURSOR c_angajati IS
--         SELECT employee_id, first_name || ' ' || last_name, department_id
--         FROM employees;
--     numedept departments.department_name%TYPE;
--     idmgr employees.manager_id%TYPE;
--     numeang VARCHAR2(50);
--     dataang employees.hire_date%TYPE;
--     anivechime NUMBER;
--     salmaxdept NUMBER;
--     comision NUMBER;
-- BEGIN
--     DELETE FROM temp_puncte;

--     FOR ang IN c_angajati LOOP
--         puncte := F_puncte(ang.employee_id);

--         INSERT INTO temp_puncte
--         VALUES (ang.employee_id, puncte, ang.department_id);
--     END LOOP;

--     DBMS_OUTPUT.PUT_LINE(rpad('DEPARTAMENT', 20) || rpad('SALARIU MAXIM', 20) || rpad('NUME ANGAJAT', 50) || rpad('ANI VECHIME', 20) || rpad('COMISION', 20) || rpad('PUNCTAJ', 20));

--     DBMS_OUTPUT.PUT_LINE(rpad('=', 120, '='));

--     FOR contori1 IN (SELECT )



-- Afisati tarile care au urmatorii factori de risc:

--- managerul are angajati care nu fac parte din departamentul lui
--- managerii au un salariu de cel putin 2 ori mai mare decat orice salariu de sub el
