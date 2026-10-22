DECLARE @certainDate DATE = '2014-01-01'; -- Change this date to your desired threshold

SELECT COUNT(*) AS NumberOfEmployees
FROM Employees
WHERE  < @certainDate;