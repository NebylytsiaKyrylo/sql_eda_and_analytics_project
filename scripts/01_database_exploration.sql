/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve a list of all tables in the database
SELECT
    table_catalog,
    table_schema,
    table_name,
    table_type
FROM information_schema.tables;

-- Retrieve all columns for a specific table (dim_customers)
SELECT
    table_catalog,
    table_schema,
    table_name,
    column_name,
    is_nullable,
    data_type
FROM information_schema.columns
WHERE
    table_name = 'dim_customers';
