-- Create Database 'DataWarehouse'

use master;

create database DataWarehouse;

use DataWarehouse;

create schema bronze;
go
create schema silver;
go
create schema gold;
go