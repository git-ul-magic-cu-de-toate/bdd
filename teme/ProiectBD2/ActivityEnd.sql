-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER ActivityEnd
   ON  VisitorActivity 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @visitorId INT;
	DECLARE @spentTime TIME;

	SELECT TOP 1 @visitorId = va.visitor_id, @spentTime = MAX(va.duration)
	FROM inserted va
	WHERE va.visitor_id IS NOT NULL
	GROUP BY va.visitor_id
	ORDER BY MAX(va.visitor_id) DESC;

	UPDATE Visitor 
	SET total_duration = DATEADD(MINUTE, DATEDIFF(MINUTE, '0:00:00', @spentTime) + DATEDIFF(MINUTE, '0:00:00', total_duration), '0:00:00')
	WHERE visitor_id = @visitorId;
END
GO
