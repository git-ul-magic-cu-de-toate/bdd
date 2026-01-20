create procedure addWishlist
@username nvarchar(50),
@id_product bigint
as
	insert into Wishlist (username, product_id)
	values (@username, @id_product)
return;
