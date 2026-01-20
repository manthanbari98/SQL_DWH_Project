--==============================
--ADVANCED DATA ANALYSIS
--==============================
--CHANGE-OVER-TIME ANALYSIS
SELECT
	FORMAT(o.order_date,'yyyy-MMM') AS order_month,
	SUM(s.quantity * s.unit_price) AS sales,
	SUM(s.quantity) AS total_quantity,
	COUNT(o.customer_id) AS total_customers,
	COUNT(*) AS total_orders
FROM gold.orders o
LEFT JOIN gold.sales s
ON o.order_id = s.order_id
GROUP BY FORMAT(o.order_date,'yyyy-MMM');

--CUMULATIVE ANALYSIS
SELECT 
	order_month,
	sales,
	SUM(sales) OVER(ORDER BY (order_month)) cumulative_sales
FROM
(SELECT
	DATETRUNC(MONTH,o.order_date) AS order_month,
	SUM(s.quantity * s.unit_price) AS sales
FROM gold.orders o
LEFT JOIN gold.sales s
ON o.order_id = s.order_id
GROUP BY DATETRUNC(MONTH,o.order_date))t;

--PERFORMANCE ANALYSIS
WITH yearly_category_sales AS
(SELECT
	YEAR(o.order_date) AS order_year,
	p.category_name,
	SUM(s.quantity * s.unit_price) AS sales
FROM gold.orders o
LEFT JOIN gold.sales s ON
o.order_id = s.order_id
LEFT JOIN gold.products p ON
s.product_id = p.product_id
GROUP BY p.category_name, YEAR(o.order_date)
)

SELECT
	order_year,
	category_name,
	sales,
	AVG(sales) OVER(PARTITION BY category_name) AS avg_calegory_sale,
	CASE
	WHEN sales > AVG(sales) OVER(PARTITION BY category_name) THEN 'ABOVE AVG'
	WHEN sales < AVG(sales) OVER(PARTITION BY category_name) THEN 'BELOW AVG'
	ELSE 'AVG'
	END AS performance,
	LAG(sales) OVER(PARTITION BY category_name ORDER BY order_year) AS previous_sale
FROM yearly_category_sales
ORDER BY category_name,order_year;

--PART-TO-WHOLE ANALYSIS
WITH category_sale_distribution AS (
SELECT
	p.category_name,
	SUM(s.quantity * s.unit_price) AS sales
FROM gold.products p
LEFT JOIN gold.sales s ON
p.product_id = s.product_id
GROUP BY p.category_name
)

SELECT 
	category_name,
	sales,
	SUM(sales) OVER() as total_sales,
	(sales / SUM(sales) OVER()) *100 as percent_total_sale
FROM category_sale_distribution
ORDER BY percent_total_sale DESC;

--DATA SEGMENTATION
--GROUP CUSTOMERS AS PER SPENDING
WITH customer_purchase AS(
SELECT
	c.customer_id,
	SUM(s.quantity * s.unit_price) AS sales,
	MIN(o.order_date) AS first_order,
	MAX(o.order_date) AS last_order,
	DATEDIFF(MONTH,MIN(o.order_date),MAX(o.order_date)) life_span
FROM gold.sales s
LEFT JOIN gold.customers c
ON s.customer_id = c.customer_id
LEFT JOIN gold.orders o ON
s.order_id = o.order_id
GROUP BY c.customer_id
)

SELECT
	customer_id,
	sales,
	CASE
		WHEN sales > 75000 THEN 'VIP'
		ELSE 'ORDINARY'
	END AS sale_type,
	life_span,
	CASE
		WHEN life_span > 12 THEN 'REGULAR'
		ELSE 'NEW'
	END AS cust_type
FROM customer_purchase;

---------------------------------------------------
--REPORTING
/* 
CUSTOMER REPORT
This report consolidates key customer metrics and behaviors
*/
GO

CREATE VIEW gold.report_customer AS 
 --base query from fact
WITH fact_report AS (
SELECT
	o.order_id,
	s.product_id,
	c.customer_id,
	c.company_name,
	c.country,
	s.quantity,
	s.quantity * s.unit_price AS sales,
	o.order_date,
	o.required_date
FROM gold.orders o
LEFT JOIN gold.sales s ON
o.order_id = s.order_id
LEFT JOIN gold.customers c ON
o.customer_id = c.customer_id
)
--customer aggregations
,customer_details AS (
SELECT 
	customer_id,
	company_name,
	country,
	SUM(quantity) AS quantity,
	SUM(sales) AS total_sale,
	COUNT(order_id) AS total_orders,
	MAX(order_date) AS last_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) life_span
FROM fact_report
GROUP BY 	customer_id,
	company_name,
	country
)
--final query
SELECT
	customer_id,
	company_name,
	country,
	quantity,
	total_sale,
--segmentation as per sale
	CASE
		WHEN total_sale > 75000 THEN 'VIP'
		ELSE 'ORDINARY'
	END AS sale_type,
	total_orders,
--avg_order_value
	total_sale/total_orders AS AOV,
--monthly spending
	CASE
		WHEN life_span = 0 THEN 0
		ELSE total_sale / life_span 
	END AS monthly_spending,
	last_order,
--recent but in years
	DATEDIFF(YEAR,last_order, GETDATE()) AS recency,
	life_span,
--segmentation as per life_span
		CASE
		WHEN life_span > 12 THEN 'REGULAR'
		ELSE 'NEW'
	END AS cust_type
FROM customer_details
;
