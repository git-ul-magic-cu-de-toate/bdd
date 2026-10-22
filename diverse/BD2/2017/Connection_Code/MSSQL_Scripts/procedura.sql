


      create procedure exemplu_procedura(
        @idDept int, 
        @numeDept varchar(10) output)
      as
      begin
        select @numeDept = dname from dept where deptno = @idDept;
        select ename, hiredate, job, sal+isnull(comm, 0) venit 
            from emp where deptno = @idDept;
      end;
      
      