CREATE DATABASE PartitioningTest;
GO

USE PartitioningTest;
GO

-- Execute the data creation and insertion script
:r /scripts/create_data.sql

-- Execute the partitioning script
:r /scripts/partitioning.sql
