create procedure populateAlbums 
as
	insert into Album (artist, name, releaseYear, genre, id_product, price)
	values ('Michael Jackson', 'Number Ones', 2003, 'Pop', 1000, 20),
			('Michael Jackson', 'Xscape', 2014, 'Pop', 1001, 20),
			('Parazitii', 'Arma secreta', 2019, 'Hip-hop', 1002, 20),
			('David Bowie', 'Blackstar', 2016, 'Jazz pop', 1003, 20)

return;
