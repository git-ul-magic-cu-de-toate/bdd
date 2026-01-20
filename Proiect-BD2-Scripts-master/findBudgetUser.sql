create procedure findBudgetUser 
	@user nvarchar(50)
as
	select budget from Users 
	where username = @user
return;