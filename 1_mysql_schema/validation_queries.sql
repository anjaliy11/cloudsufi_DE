-- counts(raw)
SELECT 'categories' AS table_name, COUNT(*) AS cnt FROM categories;
SELECT 'products' AS table_name, COUNT(*) AS cnt FROM products;
SELECT 'customers' AS table_name, COUNT(*) AS cnt FROM customers;
SELECT 'sales_transactions' AS table_name, COUNT(*) AS cnt FROM sales_transactions;
SELECT 'sales_items' AS table_name, COUNT(*) AS cnt FROM sales_items;
SELECT 'vouchers' AS table_name, COUNT(*) AS cnt FROM vouchers;
SELECT 'voucher_redemptions' AS table_name, COUNT(*) AS cnt FROM voucher_redemptions;
SELECT 'returns' AS table_name, COUNT(*) AS cnt FROM returns;


SELECT SUM(total_amount) AS total_sales_amount, SUM(discount_amount) AS total_discounts, SUM(tax_amount) AS total_tax, SUM(net_amount) AS total_net FROM sales_transactions;
SELECT SUM(line_total) AS items_line_total_sum FROM sales_items;


SELECT st.transaction_id, st.total_amount, SUM(si.line_total) AS items_sum
FROM sales_transactions st
JOIN sales_items si ON st.transaction_id = si.transaction_id
GROUP BY st.transaction_id
HAVING ABS(st.total_amount - SUM(si.line_total)) > 0.01
LIMIT 100;

--FK checks
SELECT si.* FROM sales_items si LEFT JOIN sales_transactions st ON si.transaction_id = st.transaction_id WHERE st.transaction_id IS NULL LIMIT 20;
SELECT si.* FROM sales_items si LEFT JOIN products p ON si.product_id = p.product_id WHERE p.product_id IS NULL LIMIT 20;
SELECT st.* FROM sales_transactions st LEFT JOIN customers c ON st.customer_id = c.customer_id WHERE st.customer_id IS NOT NULL AND c.customer_id IS NULL LIMIT 20;
SELECT vr.* FROM voucher_redemptions vr LEFT JOIN vouchers v ON vr.voucher_id = v.voucher_id WHERE v.voucher_id IS NULL LIMIT 20;
SELECT r.* FROM returns r LEFT JOIN sales_items si ON r.item_id = si.item_id WHERE r.item_id IS NOT NULL AND si.item_id IS NULL LIMIT 20;


SELECT COUNT(*) AS missing_transaction_date FROM sales_transactions WHERE transaction_date IS NULL OR transaction_time IS NULL;
SELECT COUNT(*) AS missing_product_name FROM products WHERE product_name IS NULL;


SELECT email, COUNT(*) FROM customers GROUP BY email HAVING COUNT(*) > 1;
SELECT voucher_code, COUNT(*) FROM vouchers GROUP BY voucher_code HAVING COUNT(*) > 1;

SELECT customer_id, SUM(net_amount) AS total_spend FROM sales_transactions GROUP BY customer_id ORDER BY total_spend DESC LIMIT 10;


SELECT p.product_id, p.product_name,
       SUM(si.quantity) AS qty_sold,
       COALESCE(SUM(r.return_quantity),0) AS qty_returned,
       COALESCE(SUM(r.return_quantity),0)/NULLIF(SUM(si.quantity),0) AS return_rate
FROM products p
JOIN sales_items si ON p.product_id = si.product_id
LEFT JOIN returns r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY return_rate DESC
LIMIT 20;


SELECT 'sales_items_orphans' AS check, COUNT(*) FROM sales_items si LEFT JOIN sales_transactions st ON si.transaction_id = st.transaction_id WHERE st.transaction_id IS NULL;
SELECT 'voucher_redemptions_orphans' AS check, COUNT(*) FROM voucher_redemptions vr LEFT JOIN vouchers v ON vr.voucher_id = v.voucher_id WHERE v.voucher_id IS NULL;


