

CREATE OR REPLACE PROCEDURE
`retail-market-analysis.retailmart_dw.sp_sales_metrics`(
  IN p_start_date DATE,
  IN p_end_date DATE
)
BEGIN

  -- total revenue for particular period
  SELECT
    SAFE_CAST(SUM(line_total) AS NUMERIC) AS total_revenue
  FROM `retail-market-analysis.retailmart_dw.fact_sales`
  WHERE transaction_date BETWEEN p_start_date AND p_end_date;


  --  Monthly revenue trend
  WITH monthly_revenue AS (
    SELECT
      FORMAT_DATE('%Y-%m', transaction_date) AS year_month,
      SUM(line_total) AS revenue
    FROM `retail-market-analysis.retailmart_dw.fact_sales`
    WHERE transaction_date BETWEEN p_start_date AND p_end_date
    GROUP BY year_month
  )
  SELECT *
  FROM monthly_revenue
  ORDER BY year_month;


  -- MOM  growth
  WITH monthly AS (
    SELECT
      FORMAT_DATE('%Y-%m', transaction_date) AS year_month,
      SUM(line_total) AS revenue
    FROM `retail-market-analysis.retailmart_dw.fact_sales`
    WHERE transaction_date BETWEEN p_start_date AND p_end_date
    GROUP BY year_month
  ),
  ranked AS (
    SELECT
      year_month,
      revenue,
      ROW_NUMBER() OVER (ORDER BY year_month DESC) AS rn
    FROM monthly
  )
  SELECT
    (SELECT revenue FROM ranked WHERE rn = 1) AS last_month_revenue,
    (SELECT revenue FROM ranked WHERE rn = 2) AS previous_month_revenue,
    CASE
      WHEN (SELECT revenue FROM ranked WHERE rn = 2) IS NULL
           OR (SELECT revenue FROM ranked WHERE rn = 2) = 0
      THEN NULL
      ELSE SAFE_DIVIDE(
        (SELECT revenue FROM ranked WHERE rn = 1)
        - (SELECT revenue FROM ranked WHERE rn = 2),
        (SELECT revenue FROM ranked WHERE rn = 2)
      )
    END AS mom_growth_rate;


  --  Year-over-Year comparison
  SELECT
    SAFE_CAST(SUM(CASE
      WHEN DATE_SUB(transaction_date, INTERVAL 1 YEAR)
           BETWEEN p_start_date AND p_end_date
      THEN line_total END) AS NUMERIC) AS previous_year_revenue,

    SAFE_CAST(SUM(CASE
      WHEN transaction_date BETWEEN p_start_date AND p_end_date
      THEN line_total END) AS NUMERIC) AS current_year_revenue,

    CASE
      WHEN SAFE_CAST(SUM(CASE
        WHEN DATE_SUB(transaction_date, INTERVAL 1 YEAR)
             BETWEEN p_start_date AND p_end_date
        THEN line_total END) AS NUMERIC) = 0
      THEN NULL
      ELSE SAFE_DIVIDE(
        SAFE_CAST(SUM(CASE
          WHEN transaction_date BETWEEN p_start_date AND p_end_date
          THEN line_total END) AS NUMERIC)
        -
        SAFE_CAST(SUM(CASE
          WHEN DATE_SUB(transaction_date, INTERVAL 1 YEAR)
               BETWEEN p_start_date AND p_end_date
          THEN line_total END) AS NUMERIC),
        SAFE_CAST(SUM(CASE
          WHEN DATE_SUB(transaction_date, INTERVAL 1 YEAR)
               BETWEEN p_start_date AND p_end_date
          THEN line_total END) AS NUMERIC)
      )
    END AS yoy_growth_rate
  FROM `retail-market-analysis.retailmart_dw.fact_sales`;

END;
