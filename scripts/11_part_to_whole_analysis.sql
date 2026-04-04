/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
EXPLAIN ANALYSE
WITH total_per_category AS (
    SELECT
        dp.category,
        SUM(fs.sales_amount) AS category_sales
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
    GROUP BY
        dp.category
                           ),
     total_sales AS (
    SELECT
        *,
        SUM(category_sales) OVER () AS total
    FROM total_per_category
                           )
SELECT
    *,
    ROUND((category_sales / total) * 100, 2) AS perc_per_category
FROM total_sales;


EXPLAIN ANALYSE
SELECT
    dp.category,
    SUM(fs.sales_amount) AS category_sales,
    SUM(SUM(fs.sales_amount)) OVER () AS sales_total,
    ROUND((SUM(fs.sales_amount) / SUM(SUM(fs.sales_amount)) OVER ()) * 100, 2) AS perc_per_category
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key
GROUP BY
    dp.category