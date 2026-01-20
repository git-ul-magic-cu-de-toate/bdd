create procedure selectSongsById 
	@product_id bigint
as
	select * from Song where id_product = @product_id
return;
