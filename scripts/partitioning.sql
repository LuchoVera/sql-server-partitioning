-- Create a partition function
CREATE PARTITION FUNCTION AnnualPartitionFunction (DATE)
AS RANGE RIGHT FOR VALUES ('2019-01-01', '2020-01-01', '2021-01-01');

-- Create a partition scheme
CREATE PARTITION SCHEME AnnualPartitionScheme
AS PARTITION AnnualPartitionFunction
ALL TO ([PRIMARY]);

-- Create a partitioned table
CREATE TABLE LargeData_Partitioned (
    ID BIGINT NOT NULL,
    Date DATE NOT NULL,
    Value DECIMAL(18,2),
    Description NVARCHAR(255)
) ON AnnualPartitionScheme(Date);

-- Migrate data from the original table
INSERT INTO LargeData_Partitioned WITH (TABLOCK)
SELECT * FROM LargeData;
