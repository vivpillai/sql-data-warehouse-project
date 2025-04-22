
----CUMULATIVE ANALYSIS
--AGGREGATING DATA PROGRESSIVELY OVER TIME
---AGG CUMULATIVE MEASURE BY DATE DIMENSION

--- CALCULATE THE TOTAL SALES PER MONTH
--- AND THE RUNNING TOTAL OF SALES OVER TIME
---USE WINDOWS FUNCTIONS FOR THIS TYPE OF ANALYSIS


SELECT 
order_date,
total_sales,
SUM(total_sales) OVER(ORDER BY order_date) AS running_sales,
avg_price,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_avg
FROM 
(
SELECT 
DATETRUNC(YEAR, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR,order_date)
) T
