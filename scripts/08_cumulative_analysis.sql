/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month 
-- and the running total of sales over time with partition by year
WITH
    sales_per_month AS (
        SELECT
            EXTRACT(YEAR FROM order_date) AS order_year,
            EXTRACT(MONTH FROM order_date) AS order_month,
            SUM(sales_amount) AS total_sales
        FROM gold.fact_sales
        WHERE
            order_date IS NOT NULL
        GROUP BY
            order_year,
            order_month
        ORDER BY
            order_year,
            order_month
                       )
SELECT
    order_year,
    order_month,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY order_year ORDER BY order_year, order_month) AS running_total_ytd
FROM sales_per_month;
