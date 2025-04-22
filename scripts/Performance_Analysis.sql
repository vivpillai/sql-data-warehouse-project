

--PERFORMANCE ANALYSIS (COMPARE THE CURRENT VALUE TO A TARGET VALUE)
---FIND THE DIFFERENCE BETWEEN CURRENT(MEASURE) - TARGET(MEASURE)
---USE WINDOW FUNCTIONS FOR THIS TYPE OF ANALYSIS


---ANALYZE THE YEARLY PERFORMANCE OF PRODUCTS BY COMPARING EACH PRODUCT'S SALES TO BOTH ITS AVERAGE SALES PERFORMANCE AND THE PREVIOUS YEAR'S SALES



WITH yearly_product_sales as
(
SELECT
YEAR(s.order_date) AS order_year,
p.product_name,
SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE YEAR(s.order_date) IS NOT NULL
GROUP BY YEAR(s.order_date),
p.product_name
 )
 SELECT 
 order_year,
 product_name,
 current_sales,
  --YOY ANALYSIS---
 LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
 current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) as diff_sales,
 CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
      WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	  ELSE 'No change'
 END AS py_change,

 AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
 current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
 CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'below average'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'above average'
	ELSE 'average'
END AS  avg_change
FROM yearly_product_sales
ORDER BY product_name,order_year
