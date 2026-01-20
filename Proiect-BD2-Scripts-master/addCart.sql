create procedure addCart
@username nvarchar(50),
@id_product bigint
as
	insert into Cart (username, product_id)
	values (@username, @id_product)
return;
