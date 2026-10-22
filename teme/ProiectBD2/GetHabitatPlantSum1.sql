USE parc_eco_db;
GO

CREATE PROCEDURE GetHabitatPlantSum
    @minTotalPlantCount INT = 0
AS
BEGIN
	SET NOCOUNT ON;
    CREATE TABLE #HabitatPlantSum (
        HabitatName NVARCHAR(100),
        TotalPlantCount INT
    );

    INSERT INTO #HabitatPlantSum (HabitatName, TotalPlantCount)
    SELECT
        h.habitat_name,
        ISNULL(SUM(p.plant_count), 0) AS total_plant_count
    FROM
        Habitat h
    LEFT JOIN
        Plant p ON h.habitat_id = p.habitat_id
    WHERE
        p.plant_count IS NOT NULL
    GROUP BY
        h.habitat_id, h.habitat_name
    HAVING
        ISNULL(SUM(p.plant_count), 0) >= @minTotalPlantCount;

    SELECT * FROM #HabitatPlantSum;

    DROP TABLE #HabitatPlantSum;
END;
