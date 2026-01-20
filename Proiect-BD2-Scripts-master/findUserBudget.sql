create procedure findUserBudget
	@user nvarchar(50)
as
	select dbo.selectBudgetUser(@user);
return
go