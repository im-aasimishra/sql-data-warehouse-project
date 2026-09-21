/*
=================================================
Create Database abd Schemas
=================================================
Script purpose:
	This script creates new database name 'DataWarehouse' after checking if it already exists,
	If the database exists, it is dropped and recreated. Additionally, the script sets up thress schemas
	within the database: 'bronze', 'silver', 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permanently deleted. proceed with caution
	and ensure you have proper backups before running this sccript.

*/
USE master;
GO

--Drop andrecreate the 'DataWarehouse' database
IF EXISTS (SLECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO 

CREATE SCHEMA gold;
GO
