/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/


WITH
    base_customers AS (
        -- Base Query: Retrieves core columns from tables
        SELECT
            dc.customer_id,
            dc.customer_number,
            CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, dc.birthdate)) AS age,
            fs.order_number,
            fs.product_key,
            fs.order_date,
            fs.sales_amount,
            fs.quantity
        FROM gold.fact_sales AS fs
        LEFT JOIN gold.dim_customers AS dc
            ON fs.customer_key = dc.customer_key
        WHERE
            fs.order_date IS NOT NULL
                      ),
    customer_metrics AS (
        -- Customer Aggregations: Summarizes key metrics
        SELECT
            customer_id,
            customer_number,
            customer_name,
            age,
            -- Calculate lifespan in months
            EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
            EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan_months,
            COUNT(DISTINCT order_number) AS total_orders,
            SUM(sales_amount) AS total_sales,
            SUM(quantity) AS total_quantity,
            COUNT(DISTINCT product_key) AS total_products,
            MAX(order_date) AS last_order_date
        FROM base_customers
        GROUP BY
            customer_id,
            customer_number,
            customer_name,
            age
                      ),
    customer_segmentation AS (
        -- Intermediate logic for KPIs and Segmentation
        SELECT
            *,
            -- Recency: months since last order
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order_date)) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order_date)) AS recency_months,
            -- Segmentation Logic
            CASE
                WHEN total_sales > 5000 AND lifespan_months >= 12 THEN 'VIP'
                WHEN lifespan_months >= 12 THEN 'Regular'
                ELSE 'New'
            END AS customer_segment,
            CASE
                WHEN age < 20 THEN 'Under 20'
                WHEN age BETWEEN 20 AND 39 THEN '20-39'
                WHEN age BETWEEN 40 AND 59 THEN '40-59'
                ELSE '60+'
            END AS age_group
        FROM customer_metrics
                      )
SELECT
    customer_id,
    customer_number,
    customer_name,
    age,
    age_group,
    customer_segment,
    lifespan_months,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    recency_months,
    COALESCE(ROUND(total_sales / NULLIF(total_orders, 0), 2), 0) AS avg_order_value,
    COALESCE(ROUND(total_sales / NULLIF(lifespan_months, 0), 2), 0) AS avg_monthly_spent
FROM customer_segmentation
ORDER BY
    customer_id;