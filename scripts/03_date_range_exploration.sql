/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), AGE(), EXTRACT()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months, years, days
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    MAX(order_date) - MIN(order_date) AS total_duration_days,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12 +
    EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS total_in_months,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) AS total_in_years,
    AGE(MAX(order_date), MIN(order_date)) AS duration_interval
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MIN(birthdate))) AS oldest_customer_age,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAX(birthdate))) AS younger_customer_age
FROM gold.dim_customers;