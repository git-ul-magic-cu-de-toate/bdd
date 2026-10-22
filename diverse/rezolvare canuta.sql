-- Folosind blocuri de PL/SQL vrem sa aflam:
-- Pentru fiecare locatie (city)
-- - Care este cel mai bine platit job = 1p
-- - Care este job-ul cel mai des schimbat (functia schimbata in job_history, daca nu e niciuna puneti "-") = 2p
-- - Care este job-ul cu cea mai mare margine de promovare (ne uitam cat se mai poate aloca din grila salariala, vedem ce procent este salaril actual ca suma fata de count*sal_max) = 3p
-- - Care este job-ul cel mai performant (1p de performanta / angajat daca are:
	-- salariul minim 70% din sal_max, 
	-- venitul minim 75% 
	-- macar un manager cu acel job)
-- Sugestie Afisare:
-- NumeLocatie,CelMaiBinePlatitJob,JobCeaMaiMareMargine,JobPerformantaMaxima

--REZOLVARE PL/SQL 
 
DECLARE
LOCATIE LOCATIONS%ROWTYPE;
JOB_SMECHER JOBS.job_title%TYPE;
JOB_DES_SCHIMBAT JOBS.job_title%TYPE;
JOB_HAI_CU_MARIREA_AIA JOBS.job_title%TYPE;
JOB_HABAR_NAM_DACAI_BINE JOBS.job_title%TYPE;
aux INTEGER;
aolo FLOAT;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('NumeLocatie', 35) || RPAD('CelMaiBinePlatitJob', 35) || RPAD('CelMaiSchimbatJob', 35) || RPAD('JobCeaMaiMareMargine', 35) || RPAD('JobPerformantaMaxima', 35));
    FOR LOCATIE IN (
                    SELECT * 
                    FROM LOCATIONS
                    )
    LOOP
        BEGIN
            WITH EMP_DEPTS_LOCATION AS (
                                        SELECT *
                                        FROM EMPLOYEES e
                                        JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
                                        WHERE d.location_id = LOCATIE.location_id
                                        )
            SELECT j.JOB_TITLE
            INTO JOB_SMECHER
            FROM EMP_DEPTS_LOCATION edl
            JOIN JOBS j ON edl.JOB_ID = j.JOB_ID
            WHERE edl.SALARY = (
                                SELECT MAX(edl.SALARY)
                                FROM EMP_DEPTS_LOCATION edl
                                );
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN
                JOB_SMECHER := '@';
        END;
        BEGIN
            SELECT j.JOB_TITLE, COUNT(jh.JOB_ID)
            INTO JOB_DES_SCHIMBAT, aux
            FROM job_history jh
            JOIN JOBS j ON jh.JOB_ID = j.JOB_ID
            JOIN DEPARTMENTS d ON jh.DEPARTMENT_ID = d.DEPARTMENT_ID
            WHERE d.LOCATION_ID = LOCATIE.LOCATION_ID
            GROUP BY j.JOB_TITLE
            ORDER BY 2 DESC
            FETCH FIRST 1 ROWS ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                JOB_DES_SCHIMBAT := '@';
        END;
        BEGIN
            SELECT j.JOB_TITLE, ((j.MAX_SALARY - e.SALARY) / J.MAX_SALARY)
            INTO JOB_HAI_CU_MARIREA_AIA, aolo
            FROM EMPLOYEES e
            JOIN JOBS j ON e.JOB_ID = j.JOB_ID
            JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
            WHERE d.LOCATION_ID = LOCATIE.LOCATION_ID
            ORDER BY 2 DESC
            FETCH FIRST 1 ROW ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                JOB_HAI_CU_MARIREA_AIA := '@';
        END;

        BEGIN
            WITH EMP_DEPTS_LOCATION AS (
                                        SELECT e.EMPLOYEE_ID, e.MANAGER_ID, j.JOB_TITLE, j.JOB_ID,  e.SALARY, j.MAX_SALARY, j.MIN_SALARY
                                        FROM EMPLOYEES e
                                        JOIN JOBS j ON e.JOB_ID = j.JOB_ID
                                        JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
                                        WHERE d.location_id = LOCATIE.LOCATION_ID
                                        ),
            JOB_SCORE AS (
                        SELECT edl.JOB_TITLE, 
                        CASE WHEN edl.JOB_TITLE IN ( 
                                                    SELECT DISTINCT m.JOB_TITLE  
                                                    FROM EMP_DEPTS_LOCATION edl
                                                    JOIN EMP_DEPTS_LOCATION m ON edl.MANAGER_ID = m.EMPLOYEE_ID
                                                    )
                            THEN 1 
                            ELSE 0 
                        END AS IS_MANAGER,
                        CASE WHEN 0.7 * edl.MAX_SALARY <= (
                                                        SELECT AVG(aux.SALARY)
                                                        FROM EMP_DEPTS_LOCATION aux
                                                        WHERE aux.JOB_TITLE = edl.JOB_TITLE
                                                        )
                            THEN 1
                            ELSE 0
                        END AS HAS_SALARY
                        FROM EMP_DEPTS_LOCATION edl
                        ),
            TOP_JOB as (
                        SELECT JOB_TITLE, IS_MANAGER + HAS_SALARY AS SCORE
                        FROM JOB_SCORE
                        )
            SELECT JOB_TITLE
            INTO JOB_HABAR_NAM_DACAI_BINE
            FROM TOP_JOB
            ORDER BY SCORE DESC
            FETCH FIRST 1 ROWS ONLY;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                JOB_HABAR_NAM_DACAI_BINE := '@';
        END;
    DBMS_OUTPUT.PUT_LINE(RPAD(LOCATIE.city, 35) || RPAD(JOB_SMECHER, 35) || 
    RPAD(JOB_DES_SCHIMBAT, 35) || RPAD(JOB_HAI_CU_MARIREA_AIA, 35) || 
    RPAD(JOB_HABAR_NAM_DACAI_BINE, 35));  
    END LOOP;
END;
/