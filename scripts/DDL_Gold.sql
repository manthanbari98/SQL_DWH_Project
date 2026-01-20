--========================================
--CREATE GOLD TABLES
/* SCRIPT PURPOSE : This script creates tables in the 'gold' schema after checking if it exists already.
					If table already exists, it drop the table and recreates.
*/
--========================================
use NwindDatawareHouse;
/* ===========================PRODUCTS=========================== */
IF OBJECT_ID ('gold.products','U') IS NOT NULL
	DROP TABLE gold.products;
CREATE TABLE gold.products (
product_id				INT,
product_name			NVARCHAR(100),
category_id				INT,
category_name			NVARCHAR(100),
cat_description			NVARCHAR(250),
quantity_per_unit		NVARCHAR(50),
unit_price				DECIMAL(10,2),
units_in_stock			INT,
units_on_order			INT,
reorder_level			INT,
discontinued			BIT,
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================CUSTOMERS=========================== */
IF OBJECT_ID ('gold.customers','U') IS NOT NULL
	DROP TABLE gold.customers;
CREATE TABLE gold.customers (
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
startdate				DATE,
enddate					DATE,
is_current				BIT,
record_hash				BINARY(16),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================EMPLOYEES=========================== */
IF OBJECT_ID ('gold.employees','U') IS NOT NULL
	DROP TABLE gold.employees;
CREATE TABLE gold.employees (
employee_id				INT,
last_name				NVARCHAR(50),
first_name				NVARCHAR(50),
birthdate				NVARCHAR(50),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================SALES=========================== */
IF OBJECT_ID ('gold.sales','U') IS NOT NULL
	DROP TABLE gold.sales;
CREATE TABLE gold.sales (
order_id				INT,
customer_id				NVARCHAR(50),
employee_id				INT,
product_id				INT,
supplier_id				INT,
quantity				INT,
unit_price				DECIMAL(10,2),
discount				DECIMAL(10,2),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================ORDERS=========================== */
IF OBJECT_ID ('gold.orders','U') IS NOT NULL
	DROP TABLE gold.orders;
CREATE TABLE gold.orders (
order_id				INT,
customer_id				NVARCHAR(50),
employee_id				INT,
shipper_id				INT,
freight					DECIMAL(10,2),
order_date				DATE,
required_date			DATE,
shipped_date			DATE,
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================SHIPPERS=========================== */
IF OBJECT_ID ('gold.shippers','U') IS NOT NULL
	DROP TABLE gold.shippers;
CREATE TABLE gold.shippers (
shipper_id				INT,
company_name			NVARCHAR(50),
phone					NVARCHAR(50),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

/* ===========================SUPPLIERS=========================== */
IF OBJECT_ID ('gold.suppliers','U') IS NOT NULL
	DROP TABLE gold.suppliers;
CREATE TABLE gold.suppliers (
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
startdate				DATE,
enddate					DATE,
is_current				BIT,
record_hash				BINARY(16),
dwh_creation			DATETIME2 DEFAULT GETDATE()
);
GO

