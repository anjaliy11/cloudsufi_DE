# RetailMart Analytics – End-to-End Data Engineering Project
## Project Overview

![Python](https://img.shields.io/badge/Python-3.9%2B-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-Database-blue?logo=mysql)
![BigQuery](https://img.shields.io/badge/BigQuery-Analytics-orange?logo=googlecloud)
![GCP](https://img.shields.io/badge/GCP-Cloud-yellow?logo=googlecloud)
![ETL](https://img.shields.io/badge/ETL-Pipeline-success)
![Data%20Warehouse](https://img.shields.io/badge/Data%20Warehouse-Star%20Schema-informational)
![SQL](https://img.shields.io/badge/SQL-Stored%20Procedures-lightgrey)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)


RetailMart Analytics is an end-to-end data engineering project that simulates a real-world retail analytics pipeline.
The project covers OLTP schema design, ETL development, data warehousing, and business analytics using MySQL, Python, and Google BigQuery.

The goal was to design a scalable data pipeline that transforms raw transactional data into analytics-ready insights following industry best practices.

## Architecture Summary

Source → ETL → Data Warehouse → Analytics

Source Layer: MySQL-style transactional schema (simulated via CSV exports)

ETL Layer: Python-based modular ETL pipeline

Warehouse Layer: BigQuery star schema

Analytics Layer: Parameterized SQL stored procedures

## Deliverables & Implementation
### 1. OLTP Database Design (MySQL)

### Objective:
Design a normalized transactional schema to support retail operations.

### Key Highlights:

Identified core entities: customers, products, categories, sales, returns, vouchers

Applied 3NF normalization to avoid redundancy

Enforced referential integrity using foreign keys

Added indexes on high-cardinality and frequently queried columns

Created an ER diagram to validate relationships

### Outcome:
A clean, production-ready OLTP schema suitable for downstream analytics.

## 2. Python ETL Pipeline (CSV → BigQuery)

### Objective:
Build a reliable ETL pipeline to load transactional data into BigQuery.

### Key Highlights:

Modular ETL design:

Extract: CSV ingestion with data validation

Transform: Date normalization, schema validation

Load: Automated BigQuery ingestion

Environment-based configuration using .env

Automated dataset creation

Basic logging and error handling for traceability

### Outcome:
A reusable and maintainable ETL pipeline aligned with real-world data engineering workflows.

## 3. BigQuery Data Warehouse Design

## Objective:
Create an analytics-optimized data warehouse.

### Key Highlights:

Implemented star schema

Fact tables: sales, returns

Dimension tables: date, customer, product, store

Partitioned fact tables by date to reduce query cost

Clustered tables on frequently filtered columns

Populated warehouse tables from raw datasets using SQL

### Outcome:
A scalable BigQuery warehouse optimized for reporting and BI workloads.

## 4. Business Analytics using SQL Procedures

### Objective:
Enable reusable business insights for reporting teams.

### Key Highlights:

Developed parameterized stored procedures for:

Revenue metrics (total sales, MoM, YoY)

Returns analysis (return rate, refund impact)

Used defensive SQL patterns to handle missing or sparse data

Designed procedures for direct BI tool consumption

### Outcome:
Production-ready analytics queries supporting business decision-making.


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
### Key Skills Demonstrated

- Data Modeling (OLTP & OLAP)

- Python ETL Development

- Google BigQuery & SQL Optimization

- Star Schema & Partitioning

- Cloud-based Analytics Pipelines

- Data Validation & Error Handling
