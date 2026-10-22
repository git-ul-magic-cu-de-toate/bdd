-- ex 1
-- set SERVEROUTPUT ON;
-- DECLARE
--     numeangajat VARCHAR2(50);
--     comangajat  NUMBER;
--     functie     VARCHAR2(50);
--     ecuson      employees.employee_id%TYPE;
-- BEGIN
--     ecuson := &idAngajat; -- 108

--     SELECT first_name 
--             || ' '
--             || last_name,
--             job_id,
--             commission_pct
--     INTO    numeangajat, functie, comangajat
--     FROM    employees
--     WHERE   employee_id = ecuson;

--     IF Upper(functie) = 'FI_MGR'
--         AND ( comangajat = 0
--                 OR comangajat IS NULL ) THEN
--         UPDATE  employees
--         SET     commission_pct = 0.1
--         WHERE   employee_id = ecuson;

--         DBMS_OUTPUT.PUT_LINE('Comisionul lui '
--                             || numeangajat
--                             || ' a fost modificat!');
--     END IF;
-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         DBMS_OUTPUT.PUT_LINE('Nu exista angajat cu employee_id = '
--                             || ecuson);
-- END;
-- /
-- COMMIT;
-- UNDEFINE idAngajat;

-- Sa se afiseze toti angajatii care au schimbat cel putin o data jobul

DECLARE

    TYPE info_ang IS RECORD (
        numeangajat VARCHAR2(50),
        id_ang      employees.employee_id%TYPE
    );
    TYPE date_ang IS TABLE OF info_ang;
    angajati date_ang;
    id_aux INT;

BEGIN
    SELECT  first_name
            || ' '
            || last_name,
            employee_id
    BULK COLLECT INTO angajati
    FROM employees;

    FOR i IN 1 .. angajati.COUNT LOOP
        BEGIN
            SELECT 1
            INTO id_aux
            FROM job_history
            WHERE employee_id = angajati(i).id_ang
            FETCH FIRST 1 ROWS ONLY;

            DBMS_OUTPUT.PUT_LINE('Angajatul '
                                || angajati(i).numeangajat
                                || ' a schimbat jobul');
        
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    CONTINUE;
        END;
    END LOOP;
END;

