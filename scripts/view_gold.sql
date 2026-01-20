--================================
--GOLD VIEW

/*
    Each view combines data from the gold layer 
    to produce a clean, enriched, and business-ready dataset for DA.

Purpose : Views helps in better control of data, optimization and secure the business layer
*/
--================================
IF OBJECT_ID('gold.vw_sales_analysis', 'V') IS NOT NULL
DROP VIEW gold.vw_sales_analysis;
GO
CREATE VIEW gold.vw_sales_analysis AS
SELECT
	--sales
	fs.order_id											AS [Order ID],
	fs.quantity											AS [Quantity],
	fs.unit_price										AS [Unit Price],
	fs.discount											AS [Discount Percent],
	fs.quantity * fs.unit_price * (1 - fs.discount)		AS [Sales Amount],
	--orders
	fo.order_date										AS [Order Date],
	--products
	dp.product_name										AS [Product Name],
	dp.category_name									AS [Product Category],
	--customers
	dc.company_name										AS [Customer Name],
	dc.country											AS [Customer Country],
	--employees
	de.first_name +' '+de.last_name						AS [Employee Name],
	--suppliers
	ds.company_name										AS [Supplier Company]
FROM gold.sales fs

LEFT JOIN gold.orders fo ON
fs.order_id = fo.order_id

LEFT JOIN gold.products dp ON
fs.product_id = dp.product_id

LEFT JOIN gold.customers dc ON
fs.customer_id = dc.customer_id

LEFT JOIN gold.employees de ON
fs.employee_id = de.employee_id

LEFT JOIN gold.suppliers ds ON
fs.supplier_id = ds.supplier_id;
GO
--================================
IF OBJECT_ID('gold.vw_orders_analysis', 'V') IS NOT NULL
DROP VIEW gold.vw_orders_analysis;
GO
CREATE VIEW gold.vw_orders_analysis AS
SELECT
	--orders
	fo.order_id												AS [Order ID],
	fo.freight												AS [Freight Cost],
	fo.order_date											AS [Order Date],
	fo.required_date										AS [Required Date],
	fo.shipped_date											AS [Shipped Date],
	CASE WHEN fo.shipped_date IS NOT NULL
		THEN DATEDIFF(DAY,fo.order_date,fo.shipped_date)
	END														AS [Shipping Days],
	--shippers
	ds.company_name											AS [Shipping Company]
FROM gold.orders fo
LEFT JOIN gold.shippers ds ON
fo.shipper_id = ds.shipper_id;

--==========================================
--DATE TABLE (for direct query)
GO
IF OBJECT_ID('gold.vw_calendar', 'V') IS NOT NULL
DROP VIEW gold.vw_calendar;
GO
CREATE VIEW gold.vw_calendar AS
SELECT
    CAST(d AS DATE)				AS Date,
    YEAR(d)						AS Year,
    MONTH(d)					AS MonthNumber,
	DATEPART(Q,d)				AS Quarter,
    DATENAME(MONTH, d)			AS MonthName,
    FORMAT(d,'yyyy MMM')		AS MonthYear,
	YEAR([d]) * 100 +'-'+ MONTH([d]) AS YearMonth
FROM (
    SELECT DATEADD(DAY, v.number, '1996-01-01') d
    FROM master..spt_values v
    WHERE v.type = 'P'
      AND v.number < 1000
) t;

--==================================
--DATA FRESHNESS
GO
CREATE VIEW gold.vw_data_freshness AS
SELECT
    MAX(dwh_creation) AS last_data_update
FROM gold.orders;
