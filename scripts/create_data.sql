-- Create the large table
CREATE TABLE LargeData (
    ID BIGINT IDENTITY(1,1) PRIMARY KEY,
    Date DATE NOT NULL,
    Value DECIMAL(18,2),
    Description NVARCHAR(255)
);

-- Insert bulk data
-- Insert bulk data with random distribution across partitions
DECLARE @i INT = 1;
DECLARE @random INT;

WHILE @i <= 200
BEGIN
    -- Generate a random number between 1 and 100
    SET @random = CAST(RAND() * 100 AS INT);

    INSERT INTO LargeData (Date, Value, Description)
    VALUES (
        CASE 
            WHEN @random BETWEEN 1 AND 10 THEN DATEADD(DAY, CAST(RAND() * 365 AS INT), '2018-01-01') -- 10% before 2019 (partition 1)
            WHEN @random BETWEEN 11 AND 50 THEN DATEADD(DAY, CAST(RAND() * 365 AS INT), '2019-01-01') -- 40% in 2019 (partition 2)
            WHEN @random BETWEEN 51 AND 80 THEN DATEADD(DAY, CAST(RAND() * 365 AS INT), '2020-01-01') -- 30% in 2020 (partition 3)
            ELSE DATEADD(DAY, CAST(RAND() * 365 AS INT), '2021-01-01') -- 20% in 2021 (partition 4)
        END,
        RAND() * 1000, -- Random decimal value
        CONCAT('Record_', @i) -- Unique description
    );

    SET @i = @i + 1;

    IF @i % 100000 = 0
    BEGIN
        PRINT CONCAT('Inserted ', @i, ' records');
    END
END;
