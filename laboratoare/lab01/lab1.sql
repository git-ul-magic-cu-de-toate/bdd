set SERVEROUTPUT ON
DECLARE
    idemp NUMBER(6) := &id;
    nume VARCHAR2(50);
    functie jobs.job_title%TYPE;
BEGIN
    SELECT first_name||' '||last_name, job_title
    INTO nume, functie
    FROM employees NATURAL JOIN jobs
    WHERE employee_id = idemp;
    DBMS_OUTPUT.PUT_LINE('Numele angajatului este: '|| nume || ' si are functia ' || functie);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajat cu id-ul ' || idemp);
END;
/

UNDEFINE id