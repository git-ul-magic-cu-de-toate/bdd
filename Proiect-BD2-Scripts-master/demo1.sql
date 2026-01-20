--exec addCart @username = 'malone', @id_product = 1000
/*
select * from Users;
update Users
set budget = 10000
where username = 'malone';
select * from Users; */
/*
select * from Users;
exec updateBudget @username = 'malone', @budget = 7000;
select * from Users; */

--delete from Wishlist

select budget from Users 
	where username = 'malone';

select * from Cart;

select * from Wishlist;

select product_id from Cart where username = 'malone';
select product_id from Wishlist where username = 'malone';

exec selectAlbumsById @product_id = 1001;

exec selectSongsById @product_id = 0;