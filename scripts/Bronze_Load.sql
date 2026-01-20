--=====================================
--BULK LOADING BRONZE
/* SCRIPT PURPOSE : This stored procedure loads data into the 'bronze' schema tables from source files.
					This SP performs actions like:
					~ truncate bronze tables before loading
					~ uses 'Bulk Insert' command to load data into bronze tables.

   USAGE : EXEC bronze.load_bronze;
*/
--=====================================

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	SET NOCOUNT ON;
		DECLARE @batch_id UNIQUEIDENTIFIER = NEWID(), @current_table SYSNAME;
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
			/*DECLARE @x INT = 1, @y INT = 0;			--to check error capturing
			SELECT @x / @y;*/
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		INSERT INTO dbo.etl_batch_log (
			batch_id,
			layer_name,
			procedure_name,
			batch_start_time,
			status
			)
		VALUES (
			@batch_id,
			'BRONZE',
			'bronze.load_bronze',
			@batch_start_time,
			'STARTED'
			);

/* ===========================SHIPMENTS=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.shipments';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.shipments';
		IF OBJECT_ID ('bronze.shipments','U') IS NOT NULL
		TRUNCATE TABLE bronze.shipments;
		BULK INSERT bronze.shipments
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Shipments.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================CATEGORIES=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.categories';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.categories';
		IF OBJECT_ID ('bronze.categories','U') IS NOT NULL
		TRUNCATE TABLE bronze.categories;
		BULK INSERT bronze.categories
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Categories.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================CUSTOMERS=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.customers';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.customers';
		IF OBJECT_ID ('bronze.customers','U') IS NOT NULL
		TRUNCATE TABLE bronze.customers;
		BULK INSERT bronze.customers
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Customers.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			CODEPAGE = '65001',
			--ERRORFILE = 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Customers_error.log',		--error log path
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================EMPLOYEES=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.employees';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.employees';
		IF OBJECT_ID ('bronze.employees','U') IS NOT NULL
		TRUNCATE TABLE bronze.employees;
		BULK INSERT bronze.employees
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Employees.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================ORDERDETAILS=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.orderdetails';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.orderdetails';
		IF OBJECT_ID ('bronze.orderdetails','U') IS NOT NULL
		TRUNCATE TABLE bronze.orderdetails;
		BULK INSERT bronze.orderdetails
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Orders_Details.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================ORDERS=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.orders';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.orders';
		IF OBJECT_ID ('bronze.orders','U') IS NOT NULL
		TRUNCATE TABLE bronze.orders;
		BULK INSERT bronze.orders
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Orders.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================PRODUCTS=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.products';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.products';
		IF OBJECT_ID ('bronze.products','U') IS NOT NULL
		TRUNCATE TABLE bronze.products;
		BULK INSERT bronze.products
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Product.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================SHIPPERS=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.shippers';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.shippers';
		IF OBJECT_ID ('bronze.shippers','U') IS NOT NULL
		TRUNCATE TABLE bronze.shippers;
		BULK INSERT bronze.shippers
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Shippers.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================SUPPLIERS=========================== */

		PRINT '=====================================';
		SET @current_table = 'bronze.suppliers';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE bronze.suppliers';
		IF OBJECT_ID ('bronze.suppliers','U') IS NOT NULL
		TRUNCATE TABLE bronze.suppliers;
		BULK INSERT bronze.suppliers
		FROM 'C:\Users\Manthan\OneDrive\Desktop\manthan\NWind_Data_excel\Suppliers.txt'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = '\t',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';
		SET @batch_end_time = GETDATE();

/* ===========================ERROR TESTING=========================== */
/*
--		PRINT '====================================='
--		SET @current_table = 'bronze.calc';
--		SELECT 100/0;
*/
		PRINT '====================================='

		PRINT 'TOTAL LOAD TIME : ' + CAST(DATEDIFF(SECOND,@batch_start_time, @batch_end_time) AS NVARCHAR) + ' SECONDS'

		PRINT '====================================='
/* ===========================ETL_LOG=========================== */
	UPDATE dbo.etl_batch_log
		SET 
			batch_end_time = @batch_end_time,
			status = 'SUCCESS'
		WHERE batch_id = @batch_id;
	END TRY
	BEGIN CATCH
/* ===========================ETL_ERROR=========================== */
		INSERT INTO dbo.etl_error_log(
			layer_name,
			procedure_name,
			table_name,
			error_message,
			error_number,
			error_severity,
			error_state,
			error_line,
			batch_id
		)
		VALUES (
			'BRONZE',
			ERROR_PROCEDURE(),
			@current_table,
			ERROR_MESSAGE(),
			ERROR_NUMBER(),
			ERROR_SEVERITY(),
			ERROR_STATE(),
			ERROR_LINE(),
			@batch_id
		);
		/*		
		PRINT '====================================='
		PRINT'ERROR MESSAGE :' + ERROR_MESSAGE()
		PRINT'ERROR NUMBER :' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT'ERROR STATE :' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT '====================================='
		*/
		THROW;

/* ===========================ETL_LOG=========================== */
		UPDATE dbo.etl_batch_log
		SET 
			batch_end_time = GETDATE(),
			status = 'FAILED'
		WHERE batch_id = @batch_id;
		

	END CATCH
END;
GO
