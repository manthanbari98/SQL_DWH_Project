--=====================================
--CREATE SILVER TABLES
/* SCRIPT PURPOSE : This script creates tables in the 'silver' schema after checking if it exists already.
					If table already exists, it drop the table and recreates.
*/
--=====================================

/* ===========================CATEGORY=========================== */
IF OBJECT_ID ('silver.categories','U') IS NOT NULL
	DROP TABLE silver.categories;
CREATE TABLE silver.categories (
category_id				INT,
category_name			NVARCHAR(50),
cat_description			NVARCHAR(250),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO


/* ===========================CUSTOMERS=========================== */

IF OBJECT_ID ('silver.customers','U') IS NOT NULL
	DROP TABLE silver.customers;
CREATE TABLE silver.customers (
customer_id				NVARCHAR(50),
company_name			NVARCHAR(250),
contact_name			NVARCHAR(50),
contact_title			NVARCHAR(50),
cust_address			NVARCHAR(250),
city					NVARCHAR(50),
region					NVARCHAR(50),
postal_code				NVARCHAR(50),
country					NVARCHAR(50),
phone					NVARCHAR(50),
fax						NVARCHAR(50),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================EMPLOYEES=========================== */
IF OBJECT_ID ('silver.employees','U') IS NOT NULL
	DROP TABLE silver.employees;
CREATE TABLE silver.employees (
employee_id				INT,
last_name				NVARCHAR(50),
first_name				NVARCHAR(50),
birthdate				NVARCHAR(50),
photo					NVARCHAR(50),
notes					NVARCHAR(500),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================ORDERDETAILS=========================== */
IF OBJECT_ID ('silver.orderdetails','U') IS NOT NULL
	DROP TABLE silver.orderdetails;
CREATE TABLE silver.orderdetails (
order_id				INT,
product_id				INT,
unit_price				DECIMAL(10,2),
quantity				INT,
discount				DECIMAL(10,2),
product_name			NVARCHAR(100),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);

/* ===========================ORDERS=========================== */
IF OBJECT_ID ('silver.orders','U') IS NOT NULL
	DROP TABLE silver.orders;
CREATE TABLE silver.orders (
order_id				INT,
customer_id				NVARCHAR(50),
employee_id				INT,
order_date				DATE,
required_date			DATE,
shipped_date			DATE,
ship_id					INT,
freight					DECIMAL(10,2),
ship_name				NVARCHAR(250),
ship_address			NVARCHAR(250),
ship_city				NVARCHAR(50),
ship_region				NVARCHAR(50),
ship_postal_code		NVARCHAR(50),
ship_country			NVARCHAR(50),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================PRODUCTS=========================== */
IF OBJECT_ID ('silver.products','U') IS NOT NULL
	DROP TABLE silver.products;
CREATE TABLE silver.products (
product_id				INT,
product_name			NVARCHAR(100),
supplier_id				INT,
category_id				INT,
quantity_per_unit		NVARCHAR(50),
unit_price				DECIMAL(10,2),
units_in_stock			INT,
units_on_order			INT,
reorder_level			INT,
discontinued			BIT,
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================SHIPPERS=========================== */
IF OBJECT_ID ('silver.shippers','U') IS NOT NULL
	DROP TABLE silver.shippers;
CREATE TABLE silver.shippers (
shipper_id				INT,
company_name			NVARCHAR(50),
phone					NVARCHAR(50),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================SUPPLIERS=========================== */
IF OBJECT_ID ('silver.suppliers','U') IS NOT NULL
	DROP TABLE silver.suppliers;
CREATE TABLE silver.suppliers (
supplier_id				INT,
company_name			NVARCHAR(100),
contact_name			NVARCHAR(100),
contact_title			NVARCHAR(100),
supplier_address		NVARCHAR(100),
city					NVARCHAR(100),
region					NVARCHAR(50),
postal_code				NVARCHAR(50),
country					NVARCHAR(50),
phone					NVARCHAR(50),
fax						NVARCHAR(50),
home_page				NVARCHAR(250),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

