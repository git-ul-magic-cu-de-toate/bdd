USE parc_eco_db;
GO

CREATE PROCEDURE GetHabitatAnimalSum1
    @minTotalAnimalCount INT = 0
AS
BEGIN
	SET NOCOUNT ON;
    CREATE TABLE #HabitatAnimalSum (
        HabitatName NVARCHAR(100),
        TotalAnimalCount INT
    );
    INSERT INTO #HabitatAnimalSum (HabitatName, TotalAnimalCount)
    SELECT
        h.habitat_name,
        ISNULL(SUM(a.animal_count), 0) AS total_animal_count
    FROM
        Habitat h
    LEFT JOIN
        Animal a ON h.habitat_id = a.habitat_id
    WHERE
        a.animal_count IS NOT NULL
    GROUP BY
        h.habitat_id, h.habitat_name
    HAVING
        ISNULL(SUM(a.animal_count), 0) >= @minTotalAnimalCount;

    SELECT * FROM #HabitatAnimalSum;

    DROP TABLE #HabitatAnimalSum;
END;
