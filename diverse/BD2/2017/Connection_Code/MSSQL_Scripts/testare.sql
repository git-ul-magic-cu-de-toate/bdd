declare @out varchar(10)
declare @idDept int = 10
exec exemplu_procedura @idDept, @out output
print @out

declare @avgsal real = 100
declare @grade real = 3
exec @avgsal = exemplu_functie @grade
print @avgsal