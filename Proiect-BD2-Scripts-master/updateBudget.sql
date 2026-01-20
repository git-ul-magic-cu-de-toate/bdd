create procedure updateBudget
@username nvarchar(50),
@budget int
as
	update Users
	set budget = @budget
	where username = @username;
return;