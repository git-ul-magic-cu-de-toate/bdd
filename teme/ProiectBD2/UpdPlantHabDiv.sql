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
CREATE TRIGGER UpdPlantHabDiv
ON Plant
AFTER UPDATE
AS
BEGIN
    DECLARE @old_habitat_id INT;
    DECLARE @new_habitat_id INT;

    SELECT @old_habitat_id = d.habitat_id,
           @new_habitat_id = i.habitat_id
    FROM deleted d
    INNER JOIN inserted i ON d.plant_species = i.plant_species;

    UPDATE Habitat
    SET diversity = diversity - 1
    WHERE habitat_id = @old_habitat_id;

    UPDATE Habitat
    SET diversity = diversity + 1
    WHERE habitat_id = @new_habitat_id;
END
GO
