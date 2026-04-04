/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
WITH
    base_products AS (
        -- 1) Base Query: Joins sales with product dimensions
        SELECT
            dp.product_id,
            dp.product_number,
            dp.product_name,
            dp.category,
            dp.subcategory,
            dp.cost,
            fs.order_number,
            fs.customer_key,
            fs.order_date,
            fs.sales_amount,
            fs.quantity
        FROM gold.dim_products AS dp
        LEFT JOIN gold.fact_sales AS fs
            ON dp.product_key = fs.product_key
        WHERE
            fs.order_date IS NOT NULL
                     ),
    product_metrics AS (
        -- 2) Product Aggregations: Summarizes metrics at product level
        SELECT
            product_id,
            product_number,
            product_name,
            category,
            subcategory,
            cost,
            -- Lifespan in months (from first sale to last sale)
            EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
            EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan_months,
            COUNT(DISTINCT order_number) AS total_orders,
            COUNT(DISTINCT customer_key) AS total_customers,
            SUM(sales_amount) AS total_revenue,
            SUM(quantity) AS total_quantity,
            MAX(order_date) AS last_sale_date
        FROM base_products
        GROUP BY
            product_id,
            product_number,
            product_name,
            category,
            subcategory,
            cost
                     ),
    product_segmentation AS (
        -- 3) Intermediate Logic: KPIs and Performance Tiering
        SELECT
            *,
            -- Recency: months since last sale
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_sale_date)) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_sale_date)) AS recency_months,
            -- Performance Segmentation based on revenue
            CASE
                WHEN total_revenue > 50000 THEN 'High-Performer'
                WHEN total_revenue >= 10000 THEN 'Mid-Range'
                ELSE 'Low-Performer'
            END AS performance_tier
        FROM product_metrics
                     )
-- 4) Final Output: Calculations with division-by-zero protection
SELECT
    product_id,
    product_number,
    product_name,
    category,
    subcategory,
    performance_tier,
    total_revenue,
    total_quantity,
    total_orders,
    total_customers,
    lifespan_months,
    recency_months,
    -- Average Order Revenue (AOR)
    COALESCE(ROUND(total_revenue / NULLIF(total_orders, 0), 2), 0) AS avg_order_revenue,
    -- Average Monthly Revenue
    COALESCE(ROUND(total_revenue / NULLIF(lifespan_months, 0), 2), 0) AS avg_monthly_revenue
FROM product_segmentation
ORDER BY
    total_revenue DESC;
