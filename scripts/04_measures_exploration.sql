/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the Total Sales
SELECT
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Find how many items are sold
SELECT
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Find the average selling price
SELECT
    ROUND(AVG(price), 2) AS avg_price
FROM gold.fact_sales;

-- Find the Total number of Orders
SELECT
    COUNT(DISTINCT order_number) AS n_orders
FROM gold.fact_sales;

-- Find the total number of products
SELECT
    COUNT(product_id) AS n_products
FROM gold.dim_products;

SELECT
    COUNT(DISTINCT product_name) AS n_products
FROM gold.dim_products;

-- Find the total number of customers
SELECT
    COUNT(customer_id) AS n_customers
FROM gold.dim_customers;

SELECT
    COUNT(DISTINCT customer_id) AS n_customers
FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT
    COUNT(DISTINCT customer_key) AS n_customers
FROM gold.fact_sales;

-- Generate a Report that shows all key metrics of the business
SELECT
    'total_sales' AS key_metrics,
    SUM(sales_amount) AS values
FROM gold.fact_sales
UNION ALL
SELECT
    'total_quantity',
    SUM(quantity)
FROM gold.fact_sales
UNION ALL
SELECT
    'average_price',
    ROUND(AVG(price), 2)
FROM gold.fact_sales
UNION ALL
SELECT
    'total_orders',
    COUNT(DISTINCT order_number) AS n_orders
FROM gold.fact_sales
UNION ALL
SELECT
    'total_products',
    COUNT(product_id) AS n_products
FROM gold.dim_products
UNION ALL
SELECT DISTINCT
    'total_customers',
    COUNT(customer_id) AS n_customers
FROM gold.dim_customers;

