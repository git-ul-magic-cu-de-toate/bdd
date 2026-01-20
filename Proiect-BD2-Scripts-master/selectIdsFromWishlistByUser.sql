create procedure selectIdsFromWishlistByUser
	@user nvarchar(50)
as
	select product_id from Wishlist where username = @user;
return;