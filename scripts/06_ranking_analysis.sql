/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER()
    - Clauses: GROUP BY, ORDER BY, WITH
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking
SELECT
    dp.product_id,
    dp.product_name,
    SUM(fs.sales_amount) AS total_amount
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key
GROUP BY
    dp.product_id,
    dp.product_name
ORDER BY
    total_amount DESC
LIMIT 5;

-- Complex but Flexibly Ranking Using Window Functions and CTE
WITH top_prod AS (
    SELECT
        dp.product_id AS product_id,
        dp.product_name AS product_name,
        SUM(fs.sales_amount) AS total_amount,
        DENSE_RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS ranking
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products dp
        ON fs.product_key = dp.product_key
    GROUP BY
        dp.product_id,
        dp.product_name
                 )
SELECT
    product_id,
    product_name,
    total_amount,
    ranking
FROM top_prod
WHERE
    ranking <= 5
ORDER BY
    ranking ASC;

-- What are the 5 worst-performing products in terms of sales but > 0
WITH top_prod AS (
    SELECT
        dp.product_id AS product_id,
        dp.product_name AS product_name,
        SUM(fs.quantity) AS total_quantity,
        SUM(fs.sales_amount) AS total_amount,
        DENSE_RANK() OVER (ORDER BY SUM(fs.sales_amount) ASC) AS ranking
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    GROUP BY
        dp.product_id,
        dp.product_name
                 )
SELECT
    product_id,
    product_name,
    total_quantity,
    total_amount,
    ranking
FROM top_prod
WHERE
    ranking <= 5
ORDER BY
    ranking ASC;

-- Find the top 10 customers who have generated the highest revenue
WITH top_cust AS (
    SELECT
        dc.customer_id AS customer_id,
        SUM(fs.sales_amount) AS total_revenue,
        DENSE_RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS ranking
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers dc
        ON fs.customer_key = dc.customer_key
    GROUP BY
        dc.customer_id,
        dc.first_name
                 )
SELECT
    customer_id,
    total_revenue,
    ranking
FROM top_cust
WHERE
    ranking <= 10
ORDER BY
    ranking;

-- The 3 customers with the fewest orders placed but > 0
WITH orders AS (
    SELECT
        dc.customer_id,
        dc.first_name,
        COUNT(fs.order_number) AS n_orders,
        DENSE_RANK() OVER (ORDER BY COUNT(fs.order_number) ASC) AS ranking
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers dc
        ON fs.customer_key = dc.customer_key
    GROUP BY
        dc.customer_id,
        dc.first_name
    HAVING
        COUNT(fs.order_number) > 0 -- Exclut explicitement les comptes sans commande
               )
SELECT
    customer_id,
    first_name,
    n_orders,
    ranking
FROM orders
WHERE
    ranking <= 3
ORDER BY
    ranking ASC;
