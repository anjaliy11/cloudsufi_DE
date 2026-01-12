
CREATE TABLE IF NOT EXISTS `retail-market-analysis.retailmart_dw.dim_date` (
  date DATE NOT NULL,
  year INT64,
  quarter INT64,
  month INT64,
  day INT64,
  day_of_week INT64,
  is_weekend BOOL
);


CREATE TABLE IF NOT EXISTS `retail-market-analysis.retailmart_dw.dim_product` (
  product_id INT64 NOT NULL,
  product_name STRING,
  category_id INT64,
  category_name STRING,
  sku STRING,
  brand STRING,
  cost_price NUMERIC,
  list_price NUMERIC,
  is_active BOOL
);


CREATE TABLE IF NOT EXISTS `retail-market-analysis.retailmart_dw.dim_customer` (
  customer_id INT64 NOT NULL,
  first_name STRING,
  last_name STRING,
  email STRING,
  phone STRING,
  signup_date DATE,
  loyalty_member BOOL
);


CREATE TABLE IF NOT EXISTS `retail-market-analysis.retailmart_dw.dim_store` (
  store_id INT64 NOT NULL,
  store_name STRING,
  city STRING,
  state STRING,
  country STRING
);

CREATE TABLE IF NOT EXISTS `retail-market-analysis.retailmart_dw.fact_sales` (
  transaction_id INT64 NOT NULL,
  transaction_date DATE NOT NULL,
  store_id INT64,
  customer_id INT64,
  product_id INT64,
  quantity INT64,
  unit_price NUMERIC,
  line_total NUMERIC,
  total_discount NUMERIC,
  tax_amount NUMERIC,
  payment_method STRING,
  ingestion_timestamp TIMESTAMP
)
PARTITION BY transaction_date
CLUSTER BY product_id, customer_id, store_id;

CREATE TABLE IF NOT EXISTS `retail-market-analysis.retailmart_dw.fact_returns` (
  return_id INT64 NOT NULL,
  transaction_id INT64,
  return_date DATE NOT NULL,
  product_id INT64,
  customer_id INT64,
  return_quantity INT64,
  return_reason STRING,
  refund_amount NUMERIC,
  refund_status STRING,
  ingestion_timestamp TIMESTAMP
)
PARTITION BY return_date
CLUSTER BY product_id, customer_id;


INSERT INTO `retail-market-analysis.retailmart_dw.dim_date` (date, year, quarter, month, day, day_of_week, is_weekend)
WITH bounds AS (
  SELECT
    LEAST(IFNULL(MIN(DATE(transaction_date)), DATE('2020-01-01')), IFNULL(MIN(DATE(return_date)), DATE('2020-01-01'))) AS start_date,
    GREATEST(IFNULL(MAX(DATE(transaction_date)), DATE('2020-01-01')), IFNULL(MAX(DATE(return_date)), DATE('2020-01-01'))) AS end_date
  FROM `retail-market-analysis.retailmart_raw.sales_transactions` t
  LEFT JOIN `retail-market-analysis.retailmart_raw.returns` r ON TRUE
)
SELECT
  d AS date,
  EXTRACT(YEAR FROM d) AS year,
  EXTRACT(QUARTER FROM d) AS quarter,
  EXTRACT(MONTH FROM d) AS month,
  EXTRACT(DAY FROM d) AS day,
  EXTRACT(DAYOFWEEK FROM d) AS day_of_week,
  CASE WHEN EXTRACT(DAYOFWEEK FROM d) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend
FROM bounds, UNNEST(GENERATE_DATE_ARRAY(start_date, end_date)) AS d
WHERE NOT EXISTS (SELECT 1 FROM `retail-market-analysis.retailmart_dw.dim_date` dd WHERE dd.date = d);


INSERT INTO `retail-market-analysis.retailmart_dw.dim_product` (product_id, product_name, category_id, category_name, sku, brand, cost_price, list_price, is_active)
SELECT
  p.product_id,
  p.product_name,
  p.category_id,
  c.category_name,
  p.sku,
  p.brand,
  SAFE_CAST(p.cost_price AS NUMERIC) AS cost_price,
  SAFE_CAST(p.list_price AS NUMERIC) AS list_price,
  TRUE AS is_active
FROM `retail-market-analysis.retailmart_raw.products` p
LEFT JOIN `retail-market-analysis.retailmart_raw.categories` c USING(category_id)
WHERE NOT EXISTS (SELECT 1 FROM `retail-market-analysis.retailmart_dw.dim_product` d WHERE d.product_id = p.product_id);

-- Populate dim_customer
INSERT INTO `retail-market-analysis.retailmart_dw.dim_customer` (customer_id, first_name, last_name, email, phone, signup_date, loyalty_member)
SELECT
  customer_id,
  first_name,
  last_name,
  email,
  phone,
  SAFE_CAST(signup_date AS DATE) AS signup_date,
  FALSE AS loyalty_member
FROM `retail-market-analysis.retailmart_raw.customers`
WHERE NOT EXISTS (SELECT 1 FROM `retail-market-analysis.retailmart_dw.dim_customer` d WHERE d.customer_id = customers.customer_id);

-- Populate dim_store
INSERT INTO `retail-market-analysis.retailmart_dw.dim_store` (store_id, store_name, city, state, country)
SELECT DISTINCT
  store_id,
  NULL AS store_name,
  NULL AS city,
  NULL AS state,
  NULL AS country
FROM `retail-market-analysis.retailmart_raw.sales_transactions`
WHERE store_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM `retail-market-analysis.retailmart_dw.dim_store` s WHERE s.store_id = sales_transactions.store_id);


INSERT INTO `retail-market-analysis.retailmart_dw.fact_sales` (transaction_id, transaction_date, store_id, customer_id, product_id, quantity, unit_price, line_total, total_discount, tax_amount, payment_method, ingestion_timestamp)
SELECT
  t.transaction_id,
  DATE(t.transaction_date) AS transaction_date,
  t.store_id,
  t.customer_id,
  i.product_id,
  SAFE_CAST(i.quantity AS INT64) AS quantity,
  SAFE_CAST(i.unit_price AS NUMERIC) AS unit_price,
  SAFE_CAST(i.quantity AS INT64) * SAFE_CAST(i.unit_price AS NUMERIC) - IFNULL(SAFE_CAST(i.discount_amount AS NUMERIC), 0) AS line_total,
  IFNULL(SAFE_CAST(i.discount_amount AS NUMERIC), 0) AS total_discount,
  IFNULL(SAFE_CAST(i.tax_amount AS NUMERIC), 0) AS tax_amount,
  t.payment_method,
  CURRENT_TIMESTAMP() AS ingestion_timestamp
FROM `retail-market-analysis.retailmart_raw.sales_transactions` t
JOIN `retail-market-analysis.retailmart_raw.sales_items` i
  ON t.transaction_id = i.transaction_id
WHERE TRUE;


INSERT INTO `retail-market-analysis.retailmart_dw.fact_returns` (return_id, transaction_id, return_date, product_id, customer_id, return_quantity, return_reason, refund_amount, refund_status, ingestion_timestamp)
SELECT
  SAFE_CAST(return_id AS INT64) AS return_id,
  SAFE_CAST(transaction_id AS INT64) AS transaction_id,
  DATE(return_date) AS return_date,
  SAFE_CAST(product_id AS INT64) AS product_id,
  SAFE_CAST(customer_id AS INT64) AS customer_id,
  SAFE_CAST(return_quantity AS INT64) AS return_quantity,
  return_reason,
  SAFE_CAST(refund_amount AS NUMERIC) AS refund_amount,
  refund_status,
  CURRENT_TIMESTAMP() AS ingestion_timestamp
FROM `retail-market-analysis.retailmart_raw.returns`;
