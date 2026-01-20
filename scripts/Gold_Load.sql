--=============================
--LOADING GOLD TABLES
/* SCRIPT PURPOSE : This stored procedure loads data into the 'gold' schema tables from 'silver' schema tables.
					This SP performs actions like:
					~ truncate gold tables before loading
					~ applying suitable SCD as per tables
use NwindDatawareHouse
   USAGE : EXEC gold.load_gold;
*/
--=============================

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	DECLARE @batch_id UNIQUEIDENTIFIER = NEWID(), @current_table SYSNAME;
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	SET @batch_start_time = GETDATE();
	INSERT INTO dbo.etl_batch_log (batch_id,layer_name,procedure_name,batch_start_time,status)
	VALUES (@batch_id, 'GOLD','gold.load_gold',@batch_start_time,'STARTED')
	/* ===========================PRODUCTS=========================== */
		PRINT '=====================================';
		SET @current_table = 'gold.products';
		SET @start_time = GETDATE();
		PRINT'TRUNCATING & LOADING TABLE gold.products';
		IF OBJECT_ID('gold.products','U') IS NOT NULL
		TRUNCATE TABLE gold.products;
		INSERT INTO gold.products (
				product_id,
				product_name,
				category_id,
				category_name,
				cat_description,
				quantity_per_unit,
				unit_price,
				units_in_stock,
				units_on_order,
				reorder_level,
				discontinued
				)

		SELECT
				p.product_id,
				p.product_name,
				c.category_id,
				c.category_name,
				c.cat_description,
				p.quantity_per_unit,
				p.unit_price,
				p.units_in_stock,
				p.units_on_order,
				p.reorder_level,
				p.discontinued
		FROM silver.products AS p
		LEFT JOIN silver.categories AS c
		on p.category_id = c.category_id;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT'LOAD TIME : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' SECONDS';


	/* ===========================EMPLOYEES=========================== */
		PRINT '=====================================';
		SET @current_table = 'gold.employees';
		SET @start_time = GETDATE();
		PRINT'TRUNCATING & LOADING TABLE gold.employees';
		IF OBJECT_ID('gold.employees','U') IS NOT NULL
		TRUNCATE TABLE gold.employees;
		INSERT INTO gold.employees (
				employee_id,
				last_name,
				first_name,
				birthdate
				)

		SELECT
				employee_id,
				last_name,
				first_name,
				birthdate
		FROM silver.employees;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT'LOAD TIME : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' SECONDS';


	/* ===========================SHIPPERS=========================== */
		PRINT '=====================================';
		SET @current_table = 'gold.shippers';
		SET @start_time = GETDATE();
		PRINT'TRUNCATING & LOADING TABLE gold.shippers';
		IF OBJECT_ID('gold.shippers','U') IS NOT NULL
		TRUNCATE TABLE gold.shippers;
		INSERT INTO gold.shippers (
				shipper_id,
				company_name,
				phone
				)

		SELECT
				shipper_id,
				company_name,
				phone
				FROM silver.shippers;
		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT'LOAD TIME : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' SECONDS';

	/* ===========================CUSTOMERS=========================== */
			/* APPLYING SCD-2 USING UPDATE AND INSERT */
		PRINT '=====================================';
		SET @current_table = 'gold.customers';
		SET @start_time = GETDATE();
		PRINT'UPDATING & LOADING TABLE gold.customers';

		IF OBJECT_ID('tempdb..#src_customer') IS NOT NULL
			DROP TABLE #src_customer;

		DECLARE @summary_customer TABLE(customer_id NVARCHAR(50),act NVARCHAR(50));
		DECLARE @insert_cnt INT = 0, @update_cnt INT = 0;

		SELECT
				c.customer_id,
				c.company_name,
				c.contact_name,
				c.contact_title,
				c.cust_address,
				c.city,
				c.region,
				c.postal_code,
				c.country,
				c.phone,
				c.fax,
				o.startdate,
				CAST('9999-12-31' AS DATE) AS enddate,
				CAST(1 AS BIT) AS is_current,
				HASHBYTES('MD5',CONCAT('|',c.city,c.region,c.postal_code,c.country)) AS record_hash
		INTO #src_customer
		FROM silver.customers c
		LEFT JOIN (SELECT customer_id,min(order_date) as startdate from silver.orders group by customer_id) o
		on c.customer_id = o.customer_id;

		UPDATE t
		SET
		t.is_current = 0,
		t.enddate = GETDATE()
		OUTPUT 
		INSERTED.customer_id,'UPDATE' into @summary_customer(customer_id, act)
		FROM gold.customers t
		JOIN #src_customer s
		ON s.customer_id = t.customer_id
		AND s.record_hash <> t.record_hash
		WHERE t.is_current = 1;
	

		INSERT INTO gold.customers (
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
				fax,
				startdate,
				enddate,
				is_current,
				record_hash
				)
		OUTPUT
		INSERTED.customer_id,'INSERT' into @summary_customer(customer_id, act)
		
		SELECT
				s.customer_id,
				s.company_name,
				s.contact_name,
				s.contact_title,
				s.cust_address,
				s.city,
				s.region,
				s.postal_code,
				s.country,
				s.phone,
				s.fax,
				s.startdate,
				s.enddate,
				s.is_current,
				s.record_hash
		FROM #src_customer s 
		LEFT JOIN gold.customers t
		ON s.customer_id = t.customer_id
		AND t.is_current = 1
		WHERE t.customer_id IS NULL
		OR t.record_hash <> s.record_hash;

		INSERT INTO dbo.etl_action_log (
		batch_id,
		layer_name,
		procedure_name,
		table_name,
		insert_count,
		update_count
		)
		VALUES (
		@batch_id,
		'GOLD',
		'gold.load_gold',
		@current_table,
		(SELECT COUNT(*) FROM @summary_customer WHERE act ='INSERT'),
		(SELECT COUNT(*) FROM @summary_customer WHERE act ='UPDATE')
		);

		SELECT
		@insert_cnt = COALESCE(SUM(CASE WHEN act = 'INSERT' THEN 1 ELSE 0 END),0),
		@update_cnt = COALESCE(SUM(CASE WHEN act = 'UPDATE' THEN 1 ELSE 0 END),0)
		FROM @summary_customer;

		PRINT 'INSERTED ROWS : ' + CAST(@insert_cnt AS NVARCHAR(10));
		PRINT 'UPDATED ROWS  : ' + CAST(@update_cnt AS NVARCHAR(10));
		PRINT 'TOTAL AFFECTED: ' + CAST(@insert_cnt + @update_cnt AS NVARCHAR(10));

		SET @end_time = GETDATE();
		PRINT'LOAD TIME : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' SECONDS';


	/* ===========================SUPPLIERS=========================== */
					/* APPLYING SCD-2 USING MERGE */

		PRINT '=====================================';
		SET @current_table = 'gold.suppliers';
		SET @start_time = GETDATE();
		PRINT'UPDATING & LOADING TABLE gold.suppliers';
		IF OBJECT_ID('tempdb..#src_supplier') IS NOT NULL
		DROP TABLE #src_supplier;

		DECLARE @summary_supplier TABLE(supplier_id NVARCHAR(10),act NVARCHAR(10));

		SELECT
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
				home_page,
				CAST('1996-01-01' AS DATE)startdate,
				CAST('9999-12-31' AS DATE)enddate,
				CAST(1 AS BIT)is_current,
				HASHBYTES('MD5', CONCAT('|',supplier_address,city,region)) AS record_hash
		INTO #src_supplier
		FROM silver.suppliers ;

		MERGE gold.suppliers t
		USING #src_supplier s
		ON t.supplier_id = s.supplier_id
		AND t.is_current = 1

		WHEN MATCHED
		AND t.record_hash <> s.record_hash

		THEN
		UPDATE SET
		t.supplier_address = s.supplier_address,
		t.city = s.city,
		t.region = s.region,
		t.enddate = CAST(GETDATE() AS DATE),
		t.is_current = 0

		WHEN NOT MATCHED

		THEN
		INSERT (supplier_id,
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
				home_page,
				startdate,
				enddate,
				is_current
				)

		VALUES (s.supplier_id,
				s.company_name,
				s.contact_name,
				s.contact_title,
				s.supplier_address,
				s.city,
				s.region,
				s.postal_code,
				s.country,
				s.phone,
				s.fax,
				s.home_page,
				GETDATE(),
				CAST('9999-12-31' AS DATE),
				CAST(1 AS BIT)
				)
		OUTPUT
		INSERTED.supplier_id,
		$action into @summary_supplier(supplier_id,act);

		INSERT INTO dbo.etl_action_log (
		batch_id,
		layer_name,
		procedure_name,
		table_name,
		insert_count,
		update_count
		)
		VALUES (
		@batch_id,
		'GOLD',
		'gold.load_gold',
		@current_table,
		(SELECT COUNT(*) FROM @summary_supplier WHERE act ='INSERT'),
		(SELECT COUNT(*) FROM @summary_supplier WHERE act ='UPDATE')
		);

		SELECT
		@insert_cnt = COALESCE(SUM(CASE WHEN act = 'INSERT' THEN 1 ELSE 0 END),0),
		@update_cnt = COALESCE(SUM(CASE WHEN act = 'UPDATE' THEN 1 ELSE 0 END),0)
		FROM @summary_supplier;

		PRINT 'ROWS INSERTED : ' + CAST(@insert_cnt AS NVARCHAR(10));
		PRINT 'ROWS UPDATED : ' + CAST(@update_cnt AS NVARCHAR(10));
		PRINT 'TOTAL AFFECTED : ' + CAST(@insert_cnt + @update_cnt AS NVARCHAR(10));

		SET @end_time = GETDATE();
		PRINT'LOAD TIME : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' SECONDS';


	/* ===========================ORDERS=========================== */
		PRINT '=====================================';
		SET @current_table = 'gold.orders';
		SET @start_time = GETDATE();
		PRINT'TRUNCATING & LOADING TABLE gold.orders';
		IF OBJECT_ID('gold.orders','U') IS NOT NULL
		TRUNCATE TABLE gold.orders;
		INSERT INTO gold.orders (
				order_id,
				customer_id,
				employee_id,
				shipper_id,
				freight,
				order_date,
				required_date,
				shipped_date
				)
		SELECT
				order_id,
				customer_id,
				employee_id,
				ship_id,
				freight,
				order_date,
				required_date,
				shipped_date
		FROM silver.orders;

		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT'LOAD TIME : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' SECONDS';
	
	
	/* ===========================SALES=========================== */
		PRINT '=====================================';
		SET @current_table = 'gold.sales';
		SET @start_time = GETDATE();
		PRINT'TRUNCATING & LOADING TABLE gold.sales';
		IF OBJECT_ID('gold.sales','U') IS NOT NULL
		TRUNCATE TABLE gold.sales;
		INSERT INTO gold.sales (
				order_id,
				customer_id,
				employee_id,
				product_id,
				supplier_id,
				quantity,
				unit_price,
				discount
				)

		SELECT
				d.order_id,
				o.customer_id,
				o.employee_id,
				d.product_id,
				p.supplier_id,
				d.quantity,
				d.unit_price,
				d.discount
		FROM silver.orderdetails d
		LEFT JOIN silver.products p
		ON d.product_id = p.product_id
		LEFT JOIN silver.orders o
		ON d.order_id = o.order_id;

		PRINT'ROWS LOADED ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
		SET @end_time = GETDATE();
		PRINT'LOAD TIME : ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' SECONDS';

	/* ===========================ERROR_TESTING=========================== */
/*		PRINT '=====================================';
		SET @current_table = 'silver.calc';
		DECLARE @x INT = 1, @y INT = 0;
		SELECT @x / @y;
*/
		PRINT '=====================================';
		SET @batch_end_time = GETDATE();
		PRINT'TOTAL LOAD TIME : ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR(10));
		PRINT '=====================================';
		
	/* ===========================ETL_LOG=========================== */
		PRINT '=====================================';
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
		'gold',
		'gold.load_gold',
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

