# RetailMart Analytics – Case Study Assessment
## Overview

This project was completed as part of the RetailMart Analytics case study for the intern selection process.
The objective was to design and implement a complete data pipeline for a retail chain, starting from transactional schema design to analytics-ready reporting in BigQuery.

The work is divided into clearly defined tasks as mentioned in the challenge instructions.

## Delieverable 1: MySQL ER Diagram & Database Schema Design

### Objective:
Design a normalized OLTP schema to support retail operations such as sales, customers, products, returns, and vouchers.

### Approach:

- Started with identifying core business entities (customers, products, categories, sales, returns).

- Designed tables following normalization principles to avoid redundancy.

- Used foreign key relationships to enforce referential integrity.

- Added appropriate indexes on frequently queried columns (customer_id, product_id, transaction_id).

- Created an ER diagram to visually represent relationships and validate the schema.

### Outcome:
A clean MySQL schema that accurately models real-world retail transactions and supports downstream analytics.

## Delieverable 2: Python ETL Pipeline (Source to BigQuery)

### Objective:
Build a Python-based ETL pipeline to move data from source files (simulating MySQL exports) into BigQuery.

### Approach:

Structured the pipeline into clear stages:

- Extract: Read CSV files with validation for missing or empty data.

- Transform: Clean date fields and validate required columns.

- Load: Load data into BigQuery using the official client library.

- Environment configuration handled via .env to separate code and credentials.

- Implemented basic logging and error handling to make failures traceable.

- Dataset creation is automated if it does not already exist.

### Outcome:
A reusable and readable ETL pipeline that reliably loads raw retail data into BigQuery.

## Delieverable 3: BigQuery Data Warehouse Schema Design

### Objective:
Design an analytics-ready data warehouse using BigQuery best practices.

### Approach:

- Implemented a star schema with:

- Dimension tables: date, product, customer, store

- Fact tables: sales, returns

- Partitioned large fact tables by date for cost-efficient queries.

- Used clustering on commonly filtered columns such as product_id and customer_id.

- Populated warehouse tables from raw datasets using SQL insert statements.

### Outcome:
A scalable BigQuery data warehouse optimized for analytical queries and reporting.

## Delieverable 4: SQL Procedures for Business Analytics

### Objective:
Provide reusable SQL procedures for business-level insights.

### Approach:

- Created stored procedures in BigQuery for:

- Sales metrics (total revenue, month-over-month, year-over-year)

- Returns analysis (return rates, refund impact)

- Used parameterized date ranges to make procedures reusable.

- Ensured queries handle missing data safely using BigQuery functions.

### Outcome:
Well-structured analytics procedures that can be directly used by reporting or BI tools.


## Project Structure
```md
RetailMart-Analytics/
│
├── 1_mysql_schema/
│   ├── retailmart_schemas.sql
│   ├── validation_queries.sql
│   └── retailmart_ER_diagram.png
│
├── 2_etl/
│   ├── extract.py
│   ├── transform.py
│   ├── load_bigquery.py
│   ├── config.py
│   ├── main_etl.py
│   └── validation_results/
│       └── raw_results.json
│
├── 3_bigquery_schema/
│   └── retailmart_dw.sql
│
├── 4_sql_procedures/
│   ├── sp_sales_metrics.sql
│   └── sp_returns_analysis.sql
│
├── sample_data/
│   ├── sales_transactions.csv
│   └── returns.csv
│
├── .env.example
├── requirements.txt
└── README.md
```
---
### How to Run the Project
### Prerequisites

Python 3.9+

Google Cloud Project with BigQuery enabled

Service Account with BigQuery permissions

### Setup
```md
Create a .env file from the template:

cp .env.example .env
```
---

- Update BigQuery project, dataset, and credentials path.

### Install Dependencies
```bash
pip install -r requirements.txt
```
---

- Run ETL
```bash
python task_2_etl/main_etl.py
 ```
---
- Create Data Warehouse Tables

- Run retailmart_dw.sql in BigQuery.

- Run Analytics Procedures
```md
CALL `retail-market-analysis.retailmart_dw.sp_sales_metrics`('2024-01-01', '2024-12-31');
CALL `retail-market-analysis.retailmart_dw.sp_returns_analysis`('2024-01-01', '2024-12-31');
```
---
### Disclosure

GPT-based models were used only as a support tool to help structure code and documentation.
All schema design, SQL logic, transformations, and implementation decisions were independently developed, reviewed, and validated by me.
