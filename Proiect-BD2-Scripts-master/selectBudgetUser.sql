create function selectBudgetUser(@user nvarchar(50))
returns int
as
	begin
		declare @budget int;
		set @budget = (select budget from Users 
			where username = @user);
		return @budget;
	end
go