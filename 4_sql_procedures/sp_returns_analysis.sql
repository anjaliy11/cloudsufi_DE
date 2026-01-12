
--   p_start_date - analysis start date
--   p_end_date - analysis end date


CREATE OR REPLACE PROCEDURE
`retail-market-analysis.retailmart_dw.sp_returns_analysis`(
  IN p_start_date DATE,
  IN p_end_date DATE
)
BEGIN

  -- Returns by category
  SELECT
    COALESCE(p.category_name, 'UNKNOWN') AS category_name,
    SUM(r.return_quantity) AS returns_qty,
    SUM(r.refund_amount) AS refund_amount
  FROM `retail-market-analysis.retailmart_dw.fact_returns` r
  LEFT JOIN `retail-market-analysis.retailmart_dw.dim_product` p
    ON r.product_id = p.product_id
  WHERE r.return_date BETWEEN p_start_date AND p_end_date
  GROUP BY category_name
  ORDER BY returns_qty DESC;


  --Return rate by category
  WITH sold AS (
    SELECT
      p.category_name,
      SUM(s.quantity) AS sold_qty
    FROM `retail-market-analysis.retailmart_dw.fact_sales` s
    LEFT JOIN `retail-market-analysis.retailmart_dw.dim_product` p
      ON s.product_id = p.product_id
    WHERE s.transaction_date BETWEEN p_start_date AND p_end_date
    GROUP BY p.category_name
  ),
  returned AS (
    SELECT
      p.category_name,
      SUM(r.return_quantity) AS returns_qty
    FROM `retail-market-analysis.retailmart_dw.fact_returns` r
    LEFT JOIN `retail-market-analysis.retailmart_dw.dim_product` p
      ON r.product_id = p.product_id
    WHERE r.return_date BETWEEN p_start_date AND p_end_date
    GROUP BY p.category_name
  )
  SELECT
    COALESCE(s.category_name, r.category_name, 'UNKNOWN') AS category_name,
    IFNULL(s.sold_qty, 0) AS sold_qty,
    IFNULL(r.returns_qty, 0) AS returns_qty,
    CASE
      WHEN IFNULL(s.sold_qty, 0) = 0 THEN NULL
      ELSE SAFE_DIVIDE(IFNULL(r.returns_qty, 0), s.sold_qty)
    END AS return_rate
  FROM sold s
  FULL OUTER JOIN returned r
    ON s.category_name = r.category_name
  ORDER BY return_rate DESC NULLS LAST;


  -- Revenue impact
  WITH total_revenue AS (
    SELECT SAFE_CAST(SUM(line_total) AS NUMERIC) AS revenue
    FROM `retail-market-analysis.retailmart_dw.fact_sales`
    WHERE transaction_date BETWEEN p_start_date AND p_end_date
  ),
  total_refunds AS (
    SELECT SAFE_CAST(SUM(refund_amount) AS NUMERIC) AS refunds
    FROM `retail-market-analysis.retailmart_dw.fact_returns`
    WHERE return_date BETWEEN p_start_date AND p_end_date
  )
  SELECT
    tr.revenue,
    rf.refunds,
    CASE
      WHEN tr.revenue = 0 THEN NULL
      ELSE SAFE_DIVIDE(rf.refunds, tr.revenue)
    END AS pct_revenue_refunded
  FROM total_revenue tr, total_refunds rf;

END;
