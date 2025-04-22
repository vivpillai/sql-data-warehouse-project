---- CHANGE OVER TIME ANALYSIS
--- AGG MEASURE BY DATE DIMENSION

SELECT 
YEAR(order_date) AS yr,
SUM(sales_amount) AS annual_sales,
COUNT(DISTINCT(customer_key)) AS cust_count,
SUM(quantity) AS qty_count
FROM gold.fact_sales
WHERE order_Date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ;

SELECT
YEAR(order_date) AS yr,
MONTH(order_date) AS Mnth,
SUM(sales_amount) AS annual_sales,
COUNT(DISTINCT(customer_key)) AS cust_count,
SUM(quantity) AS qty_count
FROM gold.fact_sales
WHERE order_Date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date),  MONTH(order_date)

SELECT
DATETRUNC(YEAR,order_date) AS order_date,
SUM(sales_amount) AS annual_sales,
COUNT(DISTINCT(customer_key)) AS cust_count,
SUM(quantity) AS qty_count
FROM gold.fact_sales
WHERE order_Date IS NOT NULL
GROUP BY DATETRUNC(YEAR,order_date)
ORDER BY DATETRUNC(YEAR,order_date)