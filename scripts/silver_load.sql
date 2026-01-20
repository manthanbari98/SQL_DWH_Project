--==================================
--CLEANING AND LOADING SILVER TABLES
/* SCRIPT PURPOSE : This stored procedure loads clean and transformed data into the 'silver' schema tables from 'bronze' schema tables.
					This SP performs actions like:
					~ truncate silver tables before loading
					~ uses 'Insert Into' command to load data into silver tables.

   USAGE : EXEC silver.load_silver;
*/

--==================================
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @batch_id UNIQUEIDENTIFIER = NEWID(), @current_table SYSNAME;
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
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
		'SILVER',
		'silver.load_silver',
		@batch_start_time,
		'STARTED'
		)

/* ===========================CATEGORY=========================== */
		PRINT '=====================================';
		SET @current_table = 'silver.categories';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.categories';
		IF OBJECT_ID('silver.categories','U') IS NOT NULL
			TRUNCATE TABLE silver.categories;
			INSERT INTO silver.categories (
			category_id,
			category_name,
			cat_description
			)

			Select
			category_id,
			TRIM(category_name) as category_name,
			TRIM(REPLACE(cat_description,'"','')) as cat_description
			From bronze.categories;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================CUSTOMERS=========================== */

		PRINT '=====================================';
		SET @current_table = 'silver.customers';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.customers';
		IF OBJECT_ID('silver.customers','U') IS NOT NULL
			TRUNCATE TABLE silver.customers;
			INSERT INTO silver.customers (
			customer_id,
			company_name,
			contact_name,
			contact_title,
			cust_address,
			city,
			region,
			postal_code,
			country,
			phone,
			fax
			)

			SELECT 
			customer_id,
			company_name,
			contact_name,
			contact_title,
			TRIM(REPLACE(cust_address,'"','')) as cust_address,
			city,
			region,
			postal_code,
			country,
			phone,
			fax
			FROM bronze.customers;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================EMPLOYEES=========================== */
		PRINT '=====================================';
		SET @current_table = 'silver.employees';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.employees';
		IF OBJECT_ID('silver.employees','U') IS NOT NULL
			TRUNCATE TABLE silver.employees;
			INSERT INTO silver.employees (
			employee_id,
			last_name,
			first_name,
			birthdate,
			photo,
			notes
			)

			SELECT 
			employee_id,
			last_name,
			first_name,
			birthdate,
			photo,
			notes
			FROM bronze.employees;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================ORDERDETAILS=========================== */
		PRINT '=====================================';
		SET @current_table = 'silver.orderdetails';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.orderdetails';
		IF OBJECT_ID('silver.orderdetails','U') IS NOT NULL
			TRUNCATE TABLE silver.orderdetails;
			INSERT INTO silver.orderdetails (
			order_id,
			product_id,
			unit_price,
			quantity,
			discount,
			product_name
			)

			SELECT 
			order_id,
			product_id,
			unit_price,
			quantity,
			discount,
			product_name
			FROM bronze.orderdetails;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================ORDERS=========================== */
		PRINT '=====================================';
		SET @current_table = 'silver.orders';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.orders';
		IF OBJECT_ID('silver.orders','U') IS NOT NULL
			TRUNCATE TABLE silver.orders;
			INSERT INTO silver.orders (
			order_id,
			customer_id,
			employee_id,
			order_date,
			required_date,
			shipped_date,
			ship_id,
			freight,
			ship_name,
			ship_address,
			ship_city,
			ship_region,
			ship_postal_code,
			ship_country
			)

			SELECT 
			order_id,
			customer_id,
			employee_id,
			TRY_CONVERT(DATE,order_date,105) as order_date,
			TRY_CONVERT(DATE,required_date,105) as required_date,
			TRY_CONVERT(DATE,shipped_date,105) as shipped_date,
			ship_via,
			freight,
			ship_name,
			TRIM(REPLACE(ship_address,'"','')),
			ship_city,
			ship_region,
			ship_postal_code,
			ship_country
			FROM bronze.orders;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================PRODUCTS=========================== */
		PRINT '=====================================';
		SET @current_table = 'silver.products';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.products';
		IF OBJECT_ID('silver.products','U') IS NOT NULL
			TRUNCATE TABLE silver.products;
			INSERT INTO silver.products(
			product_id,
			product_name,
			supplier_id,
			category_id,
			quantity_per_unit,
			unit_price,
			units_in_stock,
			units_on_order,
			reorder_level,
			discontinued
			)

			SELECT 
			product_id,
			product_name,
			supplier_id,
			category_id,
			quantity_per_unit,
			unit_price,
			units_in_stock,
			units_on_order,
			reorder_level,
			discontinued
			FROM bronze.products;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================SHIPPERS=========================== */
		PRINT '=====================================';
		SET @current_table = 'silver.shippers';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.shippers';
		IF OBJECT_ID('silver.shippers','U') IS NOT NULL
			TRUNCATE TABLE silver.shippers;
			INSERT INTO silver.shippers(
			shipper_id,
			company_name,
			phone
			)

			SELECT 
			shipper_id,
			company_name,
			phone
			FROM bronze.shippers;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================SUPPLIERS=========================== */
		PRINT '=====================================';
		SET @current_table = 'silver.suppliers';
		SET @start_time = GETDATE();
		PRINT 'TRUNCATING & LOADING TABLE silver.suppliers';
		IF OBJECT_ID('silver.suppliers','U') IS NOT NULL
			TRUNCATE TABLE silver.suppliers;
			INSERT INTO silver.suppliers (
			supplier_id,
			company_name,
			contact_name,
			contact_title,
			supplier_address,
			city,
			region,
			postal_code,
			country,
			phone,
			fax,
			home_page
			)

			SELECT 
			supplier_id,
			company_name,
			contact_name,
			contact_title,
			TRIM(REPLACE(supplier_address,'"','')) as supplier_address,
			city,
			region,
			postal_code,
			country,
			phone,
			fax,
			home_page
			FROM bronze.suppliers;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT 'LOAD TIME : ' + CAST(DATEDIFF(SECOND,@start_time, @end_time) AS NVARCHAR) + ' SECONDS';

/* ===========================ERROR_TESTING=========================== */
/*		PRINT '=====================================';
		SET @current_table = 'silver.calc';
		DECLARE @x INT = 1, @y INT = 0;
		SELECT @x / @y;
*/
		PRINT '=====================================';

		SET @batch_end_time = GETDATE();
		PRINT 'BATCH LOAD TIME (SECONDS): ' 
			  + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(10));

		PRINT '=====================================';

/* ===========================ETL_LOG=========================== */
	UPDATE dbo.etl_batch_log
		SET
		batch_end_time = @batch_end_time,
		status = 'SUCCESS'
		WHERE batch_id = @batch_id;
		
	END TRY
	BEGIN CATCH
/* ===========================ETL_ERROR=========================== */
		INSERT INTO dbo.etl_error_log (
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
		'SILVER',
		'silver.load_silver',
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
		PRINT '=====================================';
*/
		THROW;
/* ===========================ETL_LOG=========================== */
	UPDATE dbo.etl_batch_log
		SET
		status = 'FAILED'
		WHERE batch_id = @batch_id;
	END CATCH
END;


