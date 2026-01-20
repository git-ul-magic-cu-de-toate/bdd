create procedure loginUser 
	@user nvarchar(50),
	@pass nvarchar(50)
as
	select * from Users 
	where username = @user
	and @pass = password
return;