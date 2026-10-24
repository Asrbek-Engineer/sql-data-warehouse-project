/*
==============================================================
Create Database and Schemas
==============================================================
Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze', 'silver' and 'gold'.

Warning:
	Running this script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permanently deleted. Proceed with caution 
	and ensure you have proper backups before running this script.
*/
use master;
go

-- Drop and recreate the 'DataWarehouse' database if it exists
if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin
	alter database DataWarehouse set single_user with rollback immediate;
	drop database DataWarehouse;
end
go

create database DataWarehouse;
go

use DataWarehouse;
go

-- Create Schemas
create schema bronze;
go

create schema silver;
go

create schema gold;
go