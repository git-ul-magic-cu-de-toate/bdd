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
CREATE TRIGGER DecAnimHabDiv
   ON  Animal 
   AFTER DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @habId INT;
	SELECT @habId = habitat_id FROM inserted;

	UPDATE Habitat SET diversity -= 1 WHERE habitat_id = @habId;
END
GO
