# SQL EDA and Analytics Project

## 1. Context: Part Two of a Two-Part Data Project

This repository is the **second part** of a two-part data project.

The first part — [sql_data_warehouse_project](https://github.com/NebylytsiaKyrylo/sql_data_warehouse_project) — built a
full Medallion-style data warehouse (Bronze, Silver, Gold layers) from raw CRM and ERP CSV sources, culminating in a
clean star schema: `gold.dim_customers`, `gold.dim_products`, and `gold.fact_sales`.

This repository picks up where that project left off. It consumes the Gold layer directly and performs structured
**Exploratory Data Analysis (EDA)** and **SQL-based analytics** to extract actionable business insights about customers,
products, and sales performance.

No additional ETL is required. The Gold layer dump is loaded automatically at container startup.


## 2. Objective

Develop SQL-based analytics to deliver detailed insights into:

- **Customer Behavior**: Segmentation, lifetime value, recency, and spending patterns
- **Product Performance**: Revenue contribution, cost tiers, and performance ranking
- **Sales Trends**: Monthly and yearly trends, cumulative totals, year-over-year growth

These insights provide stakeholders with key business metrics to support strategic decision-making.

## 3. What This Project Covers

The analysis is organized as a structured progression, moving from raw discovery to advanced reporting:

| Phase                | Scripts | Focus                                                   |
|----------------------|---------|---------------------------------------------------------|
| Database Exploration | 01 - 04 | Schema structure, dimensions, date ranges, core metrics |
| Magnitude Analysis   | 05 - 06 | Distribution and ranking across dimensions              |
| Trend Analysis       | 07 - 08 | Time-series trends and cumulative metrics               |
| Performance Analysis | 09 - 11 | YoY comparison, segmentation, contribution              |
| Business Reports     | 12 - 13 | Consolidated customer and product reports with KPIs     |


## 4. Architecture and Why It Runs in Docker

The project runs PostgreSQL 17 in a Docker container for reproducibility and portability.

Benefits:

- Identical database version and configuration across any machine
- One-command startup for local development and demonstration
- Deterministic mount points for scripts and initialization data
- Persistent volume for data durability across container restarts
- No local PostgreSQL installation required

The Gold layer dump (`init_db/data_warehouse_dump_gold.sql`) is loaded automatically on first container start via the
`/docker-entrypoint-initdb.d` Docker mechanism.

Main infrastructure file:

- [docker-compose.yml](docker-compose.yml)

Initialization file:

- [init_db/data_warehouse_dump_gold.sql](init_db/data_warehouse_dump_gold.sql)


## 5. Data Model

This project operates on the star schema built in Part 1.

![Data Model (Star Schema)](https://github.com/NebylytsiaKyrylo/sql_eda_and_analytics_project/blob/master/docs/data_model.png?raw=true)

The model consists of:

- `gold.dim_customers` — Customer master data enriched with CRM and ERP sources
- `gold.dim_products` — Product master data with category and subcategory classifications
- `gold.fact_sales` — Transactional sales records linked to both dimensions via surrogate keys


## 6. [Data Catalog](docs/data_catalog.md)

### **gold.dim_customers**

- **Purpose:** Stores customer details enriched with demographic and geographic data. Contains unique, cleaned, and
  integrated information about customers from both CRM and ERP systems.
- **Columns:**

| Column            | Data Type   | Description                                                                                   |
|:------------------|:------------|:----------------------------------------------------------------------------------------------|
| `customer_key`    | SERIAL      | Surrogate key (Primary Key) uniquely identifying each customer record in the dimension table. |
| `customer_id`     | INT         | Unique numerical identifier assigned to each customer.                                        |
| `customer_number` | TEXT        | Alphanumeric identifier representing the customer, used for tracking and referencing.         |
| `first_name`      | TEXT        | The customer's first name, as recorded in the system.                                         |
| `last_name`       | TEXT        | The customer's last name or family name.                                                      |
| `gender`          | TEXT        | The gender of the customer (e.g., 'Male', 'Female', 'n/a').                                   |
| `birthdate`       | DATE        | The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1971-10-06).                |
| `marital_status`  | TEXT        | The marital status of the customer (e.g., 'Married', 'Single').                               |
| `country`         | TEXT        | The country of residence for the customer (e.g., 'Australia').                                |
| `create_date`     | DATE        | The date and time when the customer record was created in the system.                         |
| `dwh_create_date` | TIMESTAMPTZ | Technical timestamp of record insertion into the DWH.                                         |


### **gold.dim_products**

- **Purpose:** Provides information about the products and their attributes.
- **Columns:**

| Column            | Data Type   | Description                                                                                          |
|:------------------|:------------|:-----------------------------------------------------------------------------------------------------|
| `product_key`     | SERIAL      | Surrogate key (Primary Key) uniquely identifying each product record in the product dimension table. |
| `product_id`      | INT         | A unique identifier (Natural ID) assigned to the product for internal tracking and referencing.      |
| `product_number`  | TEXT        | Business key (SKU) representing the product, often used for categorization or inventory.             |
| `product_name`    | TEXT        | Descriptive name of the product, including key details such as type, color, and size.                |
| `category_id`     | TEXT        | A unique identifier for the product's category, linking to its high-level classification.            |
| `category`        | TEXT        | The broader classification of the product (e.g., Bikes, Components) to group related items.          |
| `subcategory`     | TEXT        | A more detailed classification of the product within the category, such as product type.             |
| `product_line`    | TEXT        | The specific product line or series to which the product belongs (e.g., Road, Mountain).             |
| `cost`            | NUMERIC     | The cost or base price of the product, measured in monetary units.                                   |
| `maintenance`     | TEXT        | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').                              |
| `start_date`      | DATE        | The date when the product became available for sale or use, stored in the source system.             |
| `dwh_create_date` | TIMESTAMPTZ | Technical timestamp of record insertion into the DWH.                                                |


### **gold.fact_sales**

- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**

| Column            | Data Type   | Description                                                                           |
|:------------------|:------------|:--------------------------------------------------------------------------------------|
| `order_number`    | TEXT        | A unique alphanumeric identifier for each sales order (e.g., 'SO54496').              |
| `product_key`     | INT         | Surrogate key linking the order to the product dimension table `gold.dim_products`.   |
| `customer_key`    | INT         | Surrogate key linking the order to the customer dimension table `gold.dim_customers`. |
| `order_date`      | DATE        | The date when the order was placed                                                    |
| `shipping_date`   | DATE        | The date when the order was shipped to the customer.                                  |
| `due_date`        | DATE        | The date when the order payment was due.                                              |
| `sales_amount`    | NUMERIC     | The total monetary value of the sale for the line item.                               |
| `quantity`        | INT         | The number of units of the product ordered for the line item (e.g., 1).               |
| `price`           | NUMERIC     | The price per unit of the product for the line item.                                  |
| `dwh_create_date` | TIMESTAMPTZ | Technical timestamp of record insertion into the DWH.                                 |


## 7. Analysis Scripts

- 01 — [Database Exploration](scripts/01_database_exploration.sql)

  Structural discovery of the database schema. Lists all tables from `INFORMATION_SCHEMA.TABLES` and retrieves column
metadata for the customer dimension. Entry point for any new analyst joining the project.

- 02 — [Dimensions Exploration](scripts/02_dimensions_exploration.sql)

  Explores the unique values present in dimension tables. Lists distinct countries, product categories, subcategories, and
product names. Establishes what data domains exist before any aggregation begins.

- 03 — [Date Range Exploration](scripts/03_date_range_exploration.sql)

  Calculates temporal boundaries of the dataset. Determines the first and last order dates, total duration in days,
months, and years. Also calculates the age distribution of customers using their birthdates to identify the oldest and
youngest buyers.

- 04 — [Measures Exploration](scripts/04_measures_exploration.sql)

  Calculates core business metrics: total sales revenue, total quantity sold, average selling price, count of distinct
orders, products, and customers. Outputs a unified business metrics report using `UNION ALL` to consolidate all KPIs in
a single result set.

- 05 — [Magnitude Analysis](scripts/05_magnitude_analysis.sql)

  Distribution analysis across key dimensions. Answers questions such as: How many customers are in each country? How does
revenue distribute by product category? What is the average cost per category? Identifies where volume and value are
concentrated.

- 06 — [Ranking Analysis](scripts/06_ranking_analysis.sql)

  Identifies top and bottom performers using both simple `LIMIT` queries and advanced window functions (`RANK()`,
`DENSE_RANK()`, `ROW_NUMBER()`). Ranks top 5 and bottom 5 products by revenue, top 10 customers by revenue, and bottom
3 customers by order count. Uses CTEs for clean query structure.

- 07 — [Change Over Time Analysis](scripts/07_change_over_time_analysis.sql)

  Time-series analysis of monthly sales performance. Groups sales by year and month using both `EXTRACT()` and
`DATE_TRUNC()` approaches. Enables trend identification and seasonality detection across the full date range of the
dataset.

- 08 — [Cumulative Analysis](scripts/08_cumulative_analysis.sql)

  Calculates running totals and year-to-date (YTD) cumulative metrics. Uses `SUM() OVER (PARTITION BY year ORDER BY
month)` window functions to compute cumulative sales within each calendar year, making it easy to track pacing toward
annual targets.

- 09 — [Performance Analysis](scripts/09_performance_analysis.sql)

  Year-over-year product performance comparison. For each product, compares current year sales to the average across all
years (flagged as above/below/average) and to the prior year (flagged as increasing/decreasing/no change). Calculates
the percentage change year-over-year. Uses `LAG()` window function, CTEs, and includes `EXPLAIN ANALYSE` for query
optimization visibility.

- 10 — [Data Segmentation](scripts/10_data_segmentation.sql)

  Customer and product categorization using business rules. Products are segmented into four cost tiers: Below 100,
100-500, 500-1000, and Above 1000. Customers are segmented into three tiers: VIP (12+ months of purchase history and
more than 5000 EUR in total spending), Regular (12+ months, 5000 EUR or below), and New (less than 12 months of
history). Uses `CASE` statements for segmentation logic.

- 11 — [Part-to-Whole Analysis](scripts/11_part_to_whole_analysis.sql)

  Contribution analysis showing each product category's share of total revenue. Calculates both absolute revenue and
percentage contribution for every category. Implements two approaches: one using a CTE and one using inline window
functions. Includes `EXPLAIN ANALYSE` for performance benchmarking.

- 12 — [Customer Report](scripts/12_report_customers.sql)

  Comprehensive customer analytics report. Consolidates customer demographics with behavioral metrics into a single
output. Includes: age and age group (Under 20, 20-39, 40-59, 60+), customer segment (VIP, Regular, New), total orders,
total sales, total quantity, total products purchased, lifespan in months, recency (months since last order), average
order value, and average monthly spend. Uses multi-level CTEs and `NULLIF` for division-by-zero protection.

- 13 — [Product Report](scripts/13_report_products.sql)

  Comprehensive product analytics report. Consolidates product attributes with performance metrics. Includes: category,
subcategory, cost, performance tier (High-Performer above 50K EUR, Mid-Range 10K-50K EUR, Low-Performer below 10K EUR),
total orders, distinct customers, total revenue, total quantity, product lifespan in months, recency (months since last
sale), average order revenue (AOR), and average monthly revenue. Uses multi-level CTEs and `NULLIF` for
division-by-zero protection.


## 8. Project Structure

```text
.
|-- init_db/                              # Database initialization (runs automatically on container start)
|   `-- data_warehouse_dump_gold.sql      # Full Gold layer dump: schema, tables, procedures, and data
|
|-- scripts/                             # SQL analysis scripts organized as a structured progression
|   |-- 01_database_exploration.sql      # Schema introspection: lists tables and column metadata
|   |-- 02_dimensions_exploration.sql    # Unique values across dimension tables
|   |-- 03_date_range_exploration.sql    # Temporal boundaries and customer age distribution
|   |-- 04_measures_exploration.sql      # Core KPIs: sales, quantity, orders, customers
|   |-- 05_magnitude_analysis.sql        # Distribution analysis by country, gender, category
|   |-- 06_ranking_analysis.sql          # Top/bottom performers using window functions
|   |-- 07_change_over_time_analysis.sql # Monthly and yearly sales trend analysis
|   |-- 08_cumulative_analysis.sql       # Running totals and year-to-date cumulative metrics
|   |-- 09_performance_analysis.sql      # Year-over-year comparison with LAG() and percentage change
|   |-- 10_data_segmentation.sql         # Customer (VIP/Regular/New) and product cost tier segmentation
|   |-- 11_part_to_whole_analysis.sql    # Category revenue contribution as percentage of total
|   |-- 12_report_customers.sql          # Full customer report with KPIs and segmentation
|   `-- 13_report_products.sql           # Full product report with performance tiers and KPIs
|
|-- docs/                                # Documentation and visual assets
|   |-- data_model.png                   # Star schema ERD (dim_customers, dim_products, fact_sales)
|   |-- data_catalog.md                  # Business definitions and metadata for Gold layer tables
|   `-- requirements.md                  # Project scope and analytical objectives
|
|-- docker-compose.yml                   # Infrastructure definition
|-- LICENSE                              # MIT License
`-- README.md                            # Main project documentation
```


## 9. How to Run the Project

### 9.1 Prerequisites

- Docker Desktop installed and running
- `psql` client (optional — only needed for command-line script execution)

### 9.2 Start the Database

1. Clone the repository:

```bash
git clone https://github.com/NebylytsiaKyrylo/sql_eda_and_analytics_project.git
cd sql_eda_and_analytics_project
```

2. Start the PostgreSQL container:

```bash
docker compose up -d
```

3. Confirm the container is running and healthy:

```bash
docker ps
```

The Gold layer schema and data load automatically from `init_db/data_warehouse_dump_gold.sql` on first startup. No
additional setup steps are required.

To perform a clean reset:

```bash
docker compose down -v
docker compose up -d
```

### 9.3 Run the Analysis Scripts

You can execute the scripts using any SQL client (DBeaver, pgAdmin, DataGrip) connected to `localhost:5432`.

**Connection parameters:**

| Parameter | Value          |
|-----------|----------------|
| Host      | localhost      |
| Port      | 5432           |
| Database  | data_warehouse |
| User      | postgres       |
| Password  | postgres       |


## 10. Key SQL Techniques Used

| Technique                                    | Used In                          |
|----------------------------------------------|----------------------------------|
| `INFORMATION_SCHEMA` queries                 | 01 — schema discovery            |
| `DISTINCT`, `ORDER BY`                       | 02 — dimension exploration       |
| `MIN()`, `MAX()`, `AGE()`, `EXTRACT()`       | 03 — date range and age analysis |
| `SUM()`, `COUNT()`, `AVG()`, `UNION ALL`     | 04 — measures report             |
| `GROUP BY` with aggregations                 | 05 — magnitude analysis          |
| `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`     | 06 — ranking analysis            |
| `DATE_TRUNC()`, `EXTRACT()`                  | 07 — trend analysis              |
| `SUM() OVER (PARTITION BY ... ORDER BY ...)` | 08 — cumulative analysis         |
| `LAG()`, CTEs, `CASE`, `EXPLAIN ANALYSE`     | 09 — performance analysis        |
| `CASE`-based segmentation                    | 10 — data segmentation           |
| `SUM() OVER ()`, percentage calculation      | 11 — part-to-whole               |
| Multi-level CTEs, `NULLIF`                   | 12, 13 — business reports        |


## 11. Relationship to Part 1

| Aspect         | Part 1 (DWH)                         | Part 2 (This project)            |
|----------------|--------------------------------------|----------------------------------|
| Goal           | Build the data warehouse             | Analyze the data                 |
| Input          | Raw CSV files (CRM + ERP)            | Gold layer star schema           |
| Output         | Clean, structured Gold layer         | Business insights and KPIs       |
| Key techniques | ETL, stored procedures, data quality | EDA, window functions, reporting |
| Repository     | sql_data_warehouse_project           | sql_eda_and_analytics_project    |

The Gold layer created in Part 1 is the single source of truth for all analysis in this project. It is embedded in this
repository as a self-contained dump so that the analytics project can run independently without requiring Part 1 to be
set up first.
