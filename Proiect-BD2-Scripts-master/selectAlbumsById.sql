create procedure selectAlbumsById 
	@product_id bigint
as
	select * from Album where id_product = @product_id
return;
