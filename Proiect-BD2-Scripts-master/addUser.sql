create procedure addUser 
	@user nvarchar(50),
	@pass nvarchar(50),
	@budget int
as
	insert into Users (username, password, budget)
	values (@user, @pass, @budget)
	return