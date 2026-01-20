--===================================
--CREATE A DATABASE AND SCHEMAS
/* SCRIPT PURPOSE : This script creates a DataBase 'NWindDatawareHouse' after checking if it exists already.
					If database already exists, it drop the database and recreates. 
					The script also creates three schemas : bronze, silver, gold.

   WARNING : Running this script will drop the existing database 'NWindDatawareHouse'
			 and all the data in database will be permanently deleted.
			 Proceed with caution, ensure proper backup before running the script.
*/
--===================================

--Drop existing database if exists
USE master;

IF EXISTS ( SELECT 1 FROM SYS.DATABASES WHERE name = 'NwindDatawareHouse')
	BEGIN
		ALTER DATABASE NwindDatawareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE NwindDatawareHouse;
	END;
GO

--Create Database
CREATE DATABASE NwindDatawareHouse;
GO

--===================================
--CREATE SCHEMAS
--===================================

USE NwindDatawareHouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO


--=================================
--ERROR LOG TABLE
/*
THIS SCRIPT CAPTURES THE ERROR WHILE LOADING TABLES
*/
--=================================

CREATE TABLE dbo.etl_error_log (
error_log_id		INT IDENTITY(1,1) PRIMARY KEY,
layer_name			NVARCHAR(10),
procedure_name		SYSNAME,
table_name			SYSNAME NULL,
error_message		NVARCHAR(4000),
error_number		INT,
error_severity		INT,
error_state			INT,
error_line			INT,
batch_id			UNIQUEIDENTIFIER,
error_time			DATETIME DEFAULT GETDATE()
);
GO

--=================================
--BATCH LOG TABLE
--=================================

CREATE TABLE dbo.etl_batch_log (
batch_log_id		INT IDENTITY(1,1),
batch_id			UNIQUEIDENTIFIER,
layer_name			NVARCHAR(20),
procedure_name		SYSNAME,
batch_start_time	DATETIME NOT NULL,
batch_end_time		DATETIME NULL,
status				NVARCHAR(20) NOT NULL,
created_at			DATETIME DEFAULT GETDATE() NOT NULL
);

--=================================
--ACTION LOG TABLE
--=================================

CREATE TABLE dbo.etl_action_log (
action_id			INT IDENTITY(1,1),
batch_id			NVARCHAR(50),
layer_name			NVARCHAR(20),
procedure_name		SYSNAME,
table_name			SYSNAME,
insert_count		INT,
update_count		INT,
created_at			DATETIME DEFAULT GETDATE() NOT NULL
);


