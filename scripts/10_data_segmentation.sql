/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
WITH ranges AS (
    SELECT
        product_id,
        product_name,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100-500'
            WHEN cost >= 500 AND cost < 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
               )
SELECT
    cost_range,
    COUNT(*) AS quantity
FROM ranges
GROUP BY
    cost_range
ORDER BY
    quantity DESC;


/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH cust_lifespan AS (
    SELECT
        dc.customer_id,
        SUM(fs.sales_amount) AS t_amount,
        EXTRACT(YEAR FROM AGE(MAX(fs.order_date), MIN(fs.order_date))) * 12 +
        EXTRACT(MONTH FROM AGE(MAX(fs.order_date), MIN(fs.order_date))) AS lifespan
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS dc
        ON fs.customer_key = dc.customer_key
    GROUP BY
        dc.customer_id
                      )
SELECT
    CASE
        WHEN t_amount > 5000 AND lifespan >= 12 THEN 'VIP'
        WHEN t_amount <= 5000 AND lifespan >= 12 THEN 'Regular'
        ELSE 'New'
    END AS cust_group,
    COUNT(*) AS n_customers
FROM cust_lifespan
GROUP BY
    cust_group
ORDER BY
    n_customers DESC;