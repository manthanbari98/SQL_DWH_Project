--==================================
--EXPLORATORY DATA ANALYSIS
--==================================

--DATABASE EXPLORATION
--Explore all objects in DB:

SELECT * FROM INFORMATION_SCHEMA.TABLES;

--Explore all columns in DB:
 SELECT * FROM INFORMATION_SCHEMA.COLUMNS

 -------------------------------------
 --DIMENSIONS EXPLORATION
 --Explore customer country
 SELECT DISTINCT(country) FROM gold.customers;

 --Explore products & categories
 SELECT DISTINCT category_name,product_name FROM gold.products
 order by 1,2;

 -------------------------------------
 --DATE EXPLORATION
 SELECT MIN(order_date) FIRST_ORDER,
 MAX(order_date) LAST_ORDER,
 DATEDIFF(YEAR, MIN(order_date),MAX(order_date)) AS DATE_RANGE
 FROM gold.orders;

-------------------------------------
--MEASURES EXPLORATION
--TOTAL SALES
SELECT SUM(quantity * unit_price) TOTAL_SALES FROM gold.sales;
--QUANTITY PER PRODUCT SOLD
SELECT SUM(quantity) AS QUANTITY_SOLD FROM gold.sales;
--AVERAGE SELLING PRICE
SELECT ROUND(AVG(quantity * unit_price),2) AVG_SALING_PRICE FROM gold.sales;
--TOTAL NUMBER OF ORDERS
SELECT COUNT(*) TOTAL_ORDERS FROM gold.orders;
--TOTAL NUMBER OF PRODUCTS
SELECT COUNT(*) TOTAL_PRODUCTS FROM gold.products;
--TOTAL NUMBER OF CUSTOMERS
SELECT COUNT(*) TOTAL_CUSTOMERS FROM gold.customers;

--REPORT TO SHOW ALL ABOVE METRICS
SELECT 'TOTAL_SALES' AS measure_name, SUM(quantity * unit_price) measure_value FROM gold.sales
UNION ALL
SELECT 'TOTAL_QUANTIY' AS measure_name, SUM(quantity) AS measure_value FROM gold.sales
UNION ALL
SELECT 'AVG_PRICE' AS measure_name,ROUND(AVG(quantity * unit_price),2) measure_value FROM gold.sales
UNION ALL
SELECT 'TOTAL_ORDERS' AS measure_name, COUNT(*) measure_value FROM gold.orders
UNION ALL
SELECT 'TOTAL_PRODUCTS' AS measure_name,COUNT(*) measure_value FROM gold.products
UNION ALL
SELECT 'TOTAL_CUSTOMERS' AS measure_name,COUNT(*) measure_value FROM gold.customers
;
 
------------------------------------------
--MAGNITUDE ANALYSIS
--TOTAL CUSTOMERS BY COUNTRY
SELECT country,COUNT(*) AS cust_count FROM gold.customers GROUP BY country ORDER BY COUNT(*)DESC;
--TOTAL PRODUCTS BY CATEGORY
SELECT category_name, COUNT(*) AS product_count FROM gold.products GROUP BY category_name ORDER BY category_name;
--AVG SALES IN EACH CATEGORY
SELECT p.category_name,
	SUM(s.quantity * s.unit_price) AS sales 
FROM gold.products p
LEFT JOIN gold.sales s ON
p.product_id = s.product_id
GROUP BY p.category_name;
--AVG SALES BY COUNTRY
SELECT c.country,
	SUM(s.quantity * s.unit_price) AS sales
FROM gold.customers c
LEFT JOIN gold.sales s ON
c.customer_id = s.customer_id
GROUP BY c.country;
--TOTAL SALE BY CUSTOMER
SELECT customer_id,
	SUM(quantity * unit_price) AS sales
FROM gold.sales
GROUP BY customer_id;


--------------------------------------------
--RANKING ANALYSIS
--HIGHEST SELLING PRODUCTS
SELECT TOP 5
	p.product_name,
	SUM(s.quantity * s.unit_price) AS sales,
	ROW_NUMBER() OVER(ORDER BY SUM(s.quantity * s.unit_price) DESC) as rank_product 
FROM gold.products p
LEFT JOIN gold.sales s
ON p.product_id = s.product_id
GROUP BY p.product_name;

	--TOP CUSTOMERS
	SELECT * 
	FROM(
	SELECT
		c.company_name,
		SUM(s.quantity * s.unit_price) AS sales,
		ROW_NUMBER() OVER(ORDER BY SUM(s.quantity * s.unit_price) DESC) as rank_customer
	FROM gold.customers c
	LEFT JOIN gold.sales s ON
	c.customer_id = s.customer_id
	GROUP BY c.company_name)t 
	WHERE rank_customer <= 5;

