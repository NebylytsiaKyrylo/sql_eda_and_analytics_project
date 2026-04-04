/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
EXPLAIN ANALYSE
WITH
    yearly_perf_product AS (
        SELECT
            EXTRACT(YEAR FROM fs.order_date) AS date_year,
            dp.product_name AS product_name,
            SUM(fs.sales_amount) AS total_sales
        FROM gold.fact_sales AS fs
        LEFT JOIN gold.dim_products AS dp
            ON fs.product_key = dp.product_key
        GROUP BY
            date_year,
            dp.product_name
                           ),
    avg_and_prec_sales AS (
        SELECT
            date_year,
            product_name,
            total_sales,
            AVG(total_sales) OVER (PARTITION BY product_name) AS avg_yearly,
            COALESCE(LAG(total_sales) OVER (PARTITION BY product_name ORDER BY date_year),
                     0) AS prec_year_sales
        FROM yearly_perf_product
                           )
SELECT
    *,
    CASE
        WHEN total_sales > avg_yearly THEN 'Above average'
        WHEN total_sales < avg_yearly THEN 'Below average'
        ELSE 'Average'
    END AS avg_change,
    CASE
        WHEN total_sales > prec_year_sales AND prec_year_sales > 0 THEN 'Increasing'
        WHEN total_sales > prec_year_sales AND prec_year_sales = 0 THEN 'Starting'
        WHEN total_sales < prec_year_sales AND prec_year_sales > 0 THEN 'Decreasing'
        WHEN total_sales = prec_year_sales THEN 'No Change'
    END AS year_sales_change,
    CASE
        WHEN prec_year_sales = 0 THEN 0
        ELSE ROUND(((total_sales - prec_year_sales) / prec_year_sales) * 100, 2)
    END AS perc_year_change
FROM avg_and_prec_sales
ORDER BY
    product_name,
    date_year;