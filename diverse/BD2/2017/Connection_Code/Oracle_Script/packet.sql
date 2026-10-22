    
    
    create or replace package pck_example
    as
      procedure exemplu_procedura(idDept in dept.deptno%type, 
            numeDept out dept.dname%type, angajati out sys_refcursor);
      function exemplu_functie(gradSal in salgrade.grade%type, 
            salLow out salgrade.losal%type, salHigh out salgrade.hisal%type) return number;
    end pck_example;
    /

    create or replace package body pck_example
    as
      function exemplu_functie(gradSal in salgrade.grade%type, 
            salLow out salgrade.losal%type, salHigh out salgrade.hisal%type) return number
      is
        avgVenit number;
      begin
        select distinct losal, hisal into salLow, salHigh from salgrade where grade = gradSal;
        select round(avg(sal+nvl(comm, 0)), 2) into avgVenit 
            from emp where sal + nvl(comm, 0) between salLow and salHigh;
        return avgVenit;
      end exemplu_functie;

      procedure exemplu_procedura(idDept in dept.deptno%type, 
            numeDept out dept.dname%type, angajati out sys_refcursor)
      is
      begin
        select dname into numeDept from dept where deptno = iddept;
        open angajati for 
            select ename, hiredate, job, sal+nvl(comm, 0) venit 
            from emp where deptno = idDept;
      end exemplu_procedura;
    end pck_example;
    /
    
    