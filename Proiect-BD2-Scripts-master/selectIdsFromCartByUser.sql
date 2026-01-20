create procedure selectIdsFromCartByUser
	@user nvarchar(50)
as
	select product_id from Cart where username = @user;
return;