create procedure populateSongs 
as
	insert into Song (album, artist, title, releaseYear, genre, id_product, price)
	values (null, 'Michael Jackson', 'What More Can I Give', 2003, 'Pop', 0, 3),
			('Number Ones', 'Michael Jackson', 'One More Change', 2003, 'Pop', 1, 3),
			(null, 'Parazitii', 'Toate-s la fel', 2012, 'Hip-hop', 2, 3),
			('Blackstar', 'David Bowie', 'Lazarus', 2016, 'Jazz pop', 3, 3)

return;
