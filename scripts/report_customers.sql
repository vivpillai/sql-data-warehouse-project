 
 /* PURPOSE: THIS REPORT CONSOLIDATES KEY CUSTOMER METRICS AND BEHAVIOR
  1: GATHER ESSENTIAL FIELDS SUCH AS AGE,NAMES AND TRANSACTION DETAILS
  2: SEGMENT CUSTOMERS INTO CATEGORIES(VIP,REGULAR,NEW) AND AGE GROUPS
  3: AGGREGATES CUSTOMER_LEVEL METRICS:
    - TOTAL _ORDERS
	- TOTAL_sALES
	- TOTAL QUANTITY PURCHASED
	- TOTAL PRODUCTS
	- LIFESPAN (IN MONTHS)
  4: CALCUALTE VALUABLE KPI'S:
	- RECENCY (MONTHS SINCE LAST ORDER)
	- AVERAGE ORDER VALUE
	- AVERAGE MONTHLY SPEND

*/




 CREATE VIEW gold.report_customers AS

 -- BASE QUERY : RETRIEVES THE CORE COLUMNS FROM THE TABLE

 WITH base_query AS (
 SELECT
 s.order_number,
 s.product_key,
 s.order_date,
 s.sales_amount,
 s.quantity,
 c.customer_key,
 c.customer_number,
 CONCAT(c.first_name,' ',c.last_name) AS customer_name,
 DATEDIFF(YEAR,c.birthdate,GETDATE()) AS Age
 FROM
 gold.fact_sales s
 LEFT JOIN gold.dim_customers c
 ON s.customer_key = c.customer_key
 WHERE s.order_Date IS NOT NULL

 ),
 customer_aggregation AS
 /*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
 (
SELECT
 customer_key,
 customer_number,
 customer_name,
 Age,
 COUNT(DISTINCT(order_number)) AS total_orders,
 SUM(sales_amount) AS total_sales,
 SUM(quantity) AS total_quantity,
 COUNT(product_key) AS total_products,
 MAX(order_date) AS last_order_date,
 DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span
FROM base_query
GROUP BY customer_key,
 customer_number,
 customer_name,
 Age
 )
 SELECT 
  customer_key,
 customer_number,
 customer_name,
 Age,
 CASE WHEN age < 20 THEN 'Under 20'
	  WHEN age	between 20 AND 29 THEN '20-29'
	  WHEN age	between 30 AND 39 THEN '30-39'
	  WHEN age	between 40 AND 49 THEN '40-49'
	  ELSE '50 and Above' 
END AS age_group,
 CASE 
	WHEN life_span > 12 AND total_sales > 5000 THEN 'VIP'
	WHEN life_span > 12 AND total_sales <= 5000 THEN 'REGULAR'
	ELSE 'NEW'
END AS customer_segment,
last_order_date,
DATEDIFF(MONTH,last_order_date,GETDATE()) AS recency,
 total_orders,
 total_sales,
 total_quantity,
 total_products,
 life_span,
 --compute average order value
CASE WHEN total_orders = 0 THEN 0
ELSE total_sales /total_orders 
END AS  avg_order_value,
-- COMPUTE AVERAGE MONTHLY SPEND
CASE WHEN life_span = 0 THEN total_sales
ELSE total_sales / life_span
END AS average_monthly_spend
 FROM
 customer_aggregation


 SELECT *
 FROM gold.report_customers
