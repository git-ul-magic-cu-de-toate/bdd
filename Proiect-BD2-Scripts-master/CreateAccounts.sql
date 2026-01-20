create trigger CreateAccounts on Users
after insert
as
begin
SET NOCOUNT ON;
    INSERT INTO Accounts
    SELECT username
    FROM inserted 
end
go