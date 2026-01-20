--======================================
--CREATE BRONZE TABLES
/* SCRIPT PURPOSE : This script creates tables in the 'bronze' schema after checking if it exists already.
					If table already exists, it drops the table and recreates. 
*/
--======================================

/* ===========================SHIPMENTS=========================== */
IF OBJECT_ID ('bronze.shipments','U') IS NOT NULL
	DROP TABLE bronze.shipments;
GO
CREATE TABLE bronze.shipments (
order_id				INT,
customer_id				NVARCHAR(50),
employee_id				INT,
order_date				NVARCHAR(50),
required_date			NVARCHAR(50),
shipped_date			NVARCHAR(50),
ship_via				INT,
freight					DECIMAL(10,2),
ship_name				NVARCHAR(250),
ship_address			NVARCHAR(250),
ship_city				NVARCHAR(50),
ship_region				NVARCHAR(50),
ship_postal_code		NVARCHAR(50),
ship_country			NVARCHAR(50)
);
GO


/* ===========================CATEGORY=========================== */
IF OBJECT_ID ('bronze.categories','U') IS NOT NULL
	DROP TABLE bronze.categories;
GO
CREATE TABLE bronze.categories (
category_id				INT,
category_name			NVARCHAR(50),
cat_description			NVARCHAR(250),
picture					NVARCHAR(50)
);
GO


/* ===========================CUSTOMERS=========================== */
IF OBJECT_ID ('bronze.customers','U') IS NOT NULL
	DROP TABLE bronze.customers;
GO
CREATE TABLE bronze.customers (
customer_id				NVARCHAR(50),
company_name			NVARCHAR(250),
contact_name			NVARCHAR(50),
contact_title			NVARCHAR(50),
cust_address			NVARCHAR(MAX),
city					NVARCHAR(50),
region					NVARCHAR(50),
postal_code				NVARCHAR(50),
country					NVARCHAR(50),
phone					NVARCHAR(50),
fax						NVARCHAR(50)
);
GO


/* ===========================EMPLOYEES=========================== */
IF OBJECT_ID ('bronze.employees','U') IS NOT NULL
	DROP TABLE bronze.employees;
GO
CREATE TABLE bronze.employees (
employee_id				INT,
last_name				NVARCHAR(50),
first_name				NVARCHAR(50),
birthdate				NVARCHAR(50),
photo					NVARCHAR(50),
notes					NVARCHAR(500)
);
GO


/* ===========================ORDERDETAILS=========================== */
IF OBJECT_ID ('bronze.orderdetails','U') IS NOT NULL
	DROP TABLE bronze.orderdetails;
GO
CREATE TABLE bronze.orderdetails (
order_id				INT,
product_id				INT,
unit_price				DECIMAL(10,2),
quantity				INT,
discount				DECIMAL(10,2),
product_name			NVARCHAR(100)
);


/* ===========================ORDERS=========================== */
IF OBJECT_ID ('bronze.orders','U') IS NOT NULL
	DROP TABLE bronze.orders;
GO
CREATE TABLE bronze.orders (
order_id				INT,
customer_id				NVARCHAR(50),
employee_id				INT,
order_date				NVARCHAR(50),
required_date			NVARCHAR(50),
shipped_date			NVARCHAR(50),
ship_via				INT,
freight					DECIMAL(10,2),
ship_name				NVARCHAR(250),
ship_address			NVARCHAR(250),
ship_city				NVARCHAR(50),
ship_region				NVARCHAR(50),
ship_postal_code		NVARCHAR(50),
ship_country			NVARCHAR(50)
);
GO


/* ===========================PRODUCTS=========================== */
IF OBJECT_ID ('bronze.products','U') IS NOT NULL
	DROP TABLE bronze.products;
GO
CREATE TABLE bronze.products (
product_id				INT,
product_name			NVARCHAR(100),
supplier_id				INT,
category_id				INT,
quantity_per_unit		NVARCHAR(50),
unit_price				DECIMAL(10,2),
units_in_stock			INT,
units_on_order			INT,
reorder_level			INT,
discontinued			NVARCHAR(50)
);
GO


/* ===========================SHIPPERS=========================== */
IF OBJECT_ID ('bronze.shippers','U') IS NOT NULL
	DROP TABLE bronze.shippers;
GO
CREATE TABLE bronze.shippers (
shipper_id				INT,
company_name			NVARCHAR(50),
phone					NVARCHAR(50)
);
GO


/* ===========================SUPPLIERS=========================== */
IF OBJECT_ID ('bronze.suppliers','U') IS NOT NULL
	DROP TABLE bronze.suppliers;
GO
CREATE TABLE bronze.suppliers (
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
home_page				NVARCHAR(250)
);
GO
