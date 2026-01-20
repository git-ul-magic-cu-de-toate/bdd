CREATE PROCEDURE CheckExistingUser @User nvarchar(30)
AS
SELECT * FROM Users WHERE username = @User;
GO;