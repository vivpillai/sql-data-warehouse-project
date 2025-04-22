

---DATA SEGMENTATION
--HELPS UNDERSTAND THE CORRELATION BETWEEN TWO MEASURES
---MEASURE BY MEASURE

---SEGMENT PRODUCTS INTO COST RANGES AND COUNT HOW MANY PRODUCTS FALL INTO EACH SEGMENT

WITH product_segment AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END AS cost_range
FROM
gold.dim_products 
)
SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segment
GROUP BY
cost_range
ORDER BY total_products DESC

-----GROUP CUSTOMERS INTO EACH SEGMENTS BASED ON THEIR SPENDING BEHAVIOR
--VIP ATLEAST 12 MONTH OF HISTORY AND SPENDING MORE THAN 5000
--REGULAR ATLEAST 12 MONTHS OF HISTORY BUT SPENDING LESS THAN 5000
-- NEW LIFESPAN LESS THAN 12 MONTHS

WITH customer_behavior AS (
SELECT 
c.customer_key,
SUM(s.sales_amount) AS total_spending ,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS total_month,
CASE WHEN DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) >= 12 AND SUM(s.sales_amount) > 5000 THEN 'VIP'
	WHEN DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) >= 12 AND SUM(s.sales_amount) < 5000 THEN 'REGULAR'
	ELSE 'NEW'
END AS customer_segment
FROM 
gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY
c.customer_key

)

SELECT 
customer_segment,
COUNT(customer_key) AS Total_cust_cnt
FROM customer_behavior
GROUP BY
customer_segment
ORDER BY COUNT(customer_key) DESC
