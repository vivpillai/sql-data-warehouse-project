USE datawarehouse;

CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/

SELECT
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	s.customer_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	s.order_number
FROM 
gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
),

 product_agg AS ( /*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/

SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT(order_number)) AS order_count,
	COUNT(DISTINCT(customer_key)) AS cust_count,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span,
	MAX(order_date) AS last_date,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)),2) AS avg_selling_price
	FROM base_query 
	GROUP BY product_key,
	product_name,
	category,
	subcategory,
	cost
	)
	/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
	SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_date,
	life_span,
	DATEDIFF(MONTH,last_date,GETDATE()) as recency,
	CASE 
		WHEN total_sales > 50000 THEN 'High Performer'
		WHEN total_sales >= 10000 THEN 'Mid Range'
		ELSE 'Low Performer'
	END AS product_Segment,
	total_sales,
	total_quantity,
	CASE 
		WHEN order_count = 0 THEN 0
		ELSE total_sales / order_count
	END AS Avg_order_rev,
	CASE
		WHEN life_span = 0 THEN  0
		ELSE total_sales / life_Span
	END AS Avg_monthly_rev,
	avg_selling_price,
	order_count,
	cust_count
	FROM product_agg
	