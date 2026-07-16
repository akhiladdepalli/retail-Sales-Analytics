-- ============================================================================
-- QUERY SET 1: SALES OVERVIEW & REVENUE ANALYSIS
-- Demonstrates: GROUP BY, HAVING, Aggregate Functions, Date Functions
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- 1.1 Monthly Revenue Summary with Key Metrics
-- ============================================================================
SELECT
    TO_CHAR(DATE_TRUNC('month', t.transaction_date), 'YYYY-MM')    AS month,
    COUNT(DISTINCT t.transaction_id)                                AS total_orders,
    COUNT(DISTINCT t.customer_id)                                   AS unique_customers,
    SUM(t.total_amount)                                             AS total_revenue,
    ROUND(AVG(t.total_amount), 2)                                   AS avg_order_value,
    SUM(t.discount_amount)                                          AS total_discounts,
    ROUND(SUM(t.discount_amount) / NULLIF(SUM(t.subtotal), 0) * 100, 2)
                                                                     AS discount_rate_pct,
    SUM(ti.quantity)                                                AS total_units_sold,
    ROUND(SUM(t.total_amount) / COUNT(DISTINCT t.customer_id), 2)   AS revenue_per_customer
FROM transactions t
JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
WHERE t.order_status = 'Completed'
GROUP BY DATE_TRUNC('month', t.transaction_date)
ORDER BY month;

-- ============================================================================
-- 1.2 Revenue by Day of Week — Identify peak shopping days
-- ============================================================================
SELECT
    EXTRACT(DOW FROM transaction_date)                AS day_number,
    TO_CHAR(transaction_date, 'Day')                  AS day_name,
    COUNT(*)                                          AS total_orders,
    SUM(total_amount)                                 AS total_revenue,
    ROUND(AVG(total_amount), 2)                       AS avg_order_value,
    ROUND(SUM(total_amount) / COUNT(DISTINCT DATE(transaction_date)), 2)
                                                       AS avg_daily_revenue
FROM transactions
WHERE order_status = 'Completed'
GROUP BY
    EXTRACT(DOW FROM transaction_date),
    TO_CHAR(transaction_date, 'Day')
ORDER BY day_number;

-- ============================================================================
-- 1.3 Payment Method Analysis
-- ============================================================================
SELECT
    payment_method,
    COUNT(*)                                          AS transaction_count,
    SUM(total_amount)                                 AS total_revenue,
    ROUND(AVG(total_amount), 2)                       AS avg_order_value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_transactions,
    ROUND(SUM(total_amount) * 100.0 / SUM(SUM(total_amount)) OVER (), 2)
                                                       AS pct_of_revenue
FROM transactions
WHERE order_status = 'Completed'
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- ============================================================================
-- 1.4 Hourly Sales Distribution — Identify peak hours
-- ============================================================================
SELECT
    EXTRACT(HOUR FROM transaction_date)               AS hour_of_day,
    COUNT(*)                                          AS total_orders,
    SUM(total_amount)                                 AS total_revenue,
    ROUND(AVG(total_amount), 2)                       AS avg_order_value
FROM transactions
WHERE order_status = 'Completed'
GROUP BY EXTRACT(HOUR FROM transaction_date)
ORDER BY hour_of_day;

-- ============================================================================
-- 1.5 High-Value Orders (Orders > $500) — Identify premium transactions
-- ============================================================================
SELECT
    TO_CHAR(DATE_TRUNC('month', t.transaction_date), 'YYYY-MM') AS month,
    COUNT(*)                                                      AS high_value_orders,
    SUM(t.total_amount)                                           AS total_hv_revenue,
    ROUND(AVG(t.total_amount), 2)                                 AS avg_hv_order_value,
    MAX(t.total_amount)                                           AS max_order_value
FROM transactions t
WHERE t.order_status = 'Completed'
  AND t.total_amount > 500
GROUP BY DATE_TRUNC('month', t.transaction_date)
HAVING COUNT(*) >= 5
ORDER BY month;

-- ============================================================================
-- 1.6 Revenue by Order Status — Track cancellations and returns
-- ============================================================================
SELECT
    order_status,
    COUNT(*)                                          AS order_count,
    SUM(total_amount)                                 AS total_amount,
    ROUND(AVG(total_amount), 2)                       AS avg_amount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM transactions
GROUP BY order_status
ORDER BY order_count DESC;
