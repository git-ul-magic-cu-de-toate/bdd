

    create function exemplu_functie(@gradSal int) returns real
    as
    begin
        declare @avgVenit real
        declare @salLow real
        declare @salHigh real
        select @salLow = losal, @salHigh = hisal 
            from salgrade where grade = @gradSal
        select @avgVenit = round(avg(sal+isnull(comm, 0)), 2) 
            from emp where sal + isnull(comm, 0) between @salLow and @salHigh
        return @avgVenit
    end
    
    