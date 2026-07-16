-- ============================================================================
-- QUERY SET 4: TIME SERIES ANALYSIS
-- Demonstrates: LAG(), LEAD(), date_trunc, Moving Averages, Window Frames
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- 4.1 Month-over-Month Revenue Growth with LAG()
-- ============================================================================
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', transaction_date)::DATE      AS month,
        COUNT(DISTINCT transaction_id)                   AS total_orders,
        SUM(total_amount)                                AS revenue,
        COUNT(DISTINCT customer_id)                      AS unique_customers
    FROM transactions
    WHERE order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
    TO_CHAR(month, 'YYYY-MM')                            AS month,
    total_orders,
    revenue,
    unique_customers,
    LAG(revenue) OVER (ORDER BY month)                   AS prev_month_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month)         AS revenue_change,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) /
        NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100
    , 2)                                                  AS mom_growth_pct,
    -- 3-month moving average
    ROUND(AVG(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                                  AS revenue_3m_avg,
    -- Cumulative revenue (YTD reset each year)
    SUM(revenue) OVER (
        PARTITION BY EXTRACT(YEAR FROM month)
        ORDER BY month
    )                                                      AS ytd_revenue
FROM monthly_revenue
ORDER BY month;

-- ============================================================================
-- 4.2 Year-over-Year (YoY) Comparison
-- ============================================================================
WITH monthly_data AS (
    SELECT
        EXTRACT(YEAR FROM transaction_date)::INTEGER     AS year,
        EXTRACT(MONTH FROM transaction_date)::INTEGER    AS month,
        TO_CHAR(transaction_date, 'Mon')                 AS month_name,
        COUNT(DISTINCT transaction_id)                   AS orders,
        SUM(total_amount)                                AS revenue,
        COUNT(DISTINCT customer_id)                      AS customers
    FROM transactions
    WHERE order_status = 'Completed'
    GROUP BY
        EXTRACT(YEAR FROM transaction_date),
        EXTRACT(MONTH FROM transaction_date),
        TO_CHAR(transaction_date, 'Mon')
)
SELECT
    m2025.month,
    m2025.month_name,
    m2024.revenue                                        AS revenue_2024,
    m2025.revenue                                        AS revenue_2025,
    m2025.revenue - COALESCE(m2024.revenue, 0)           AS yoy_change,
    ROUND(
        (m2025.revenue - COALESCE(m2024.revenue, 0)) /
        NULLIF(m2024.revenue, 0) * 100
    , 2)                                                  AS yoy_growth_pct,
    m2024.orders                                         AS orders_2024,
    m2025.orders                                         AS orders_2025,
    m2024.customers                                      AS customers_2024,
    m2025.customers                                      AS customers_2025
FROM monthly_data m2025
LEFT JOIN monthly_data m2024
    ON m2025.month = m2024.month AND m2024.year = 2024
WHERE m2025.year = 2025
ORDER BY m2025.month;

-- ============================================================================
-- 4.3 Weekly Sales Trend with 4-Week Moving Average
-- ============================================================================
WITH weekly_sales AS (
    SELECT
        DATE_TRUNC('week', transaction_date)::DATE       AS week_start,
        COUNT(DISTINCT transaction_id)                   AS total_orders,
        SUM(total_amount)                                AS revenue,
        SUM(ti_qty.total_qty)                            AS units_sold
    FROM transactions t
    LEFT JOIN (
        SELECT transaction_id, SUM(quantity) AS total_qty
        FROM transaction_items
        GROUP BY transaction_id
    ) ti_qty ON t.transaction_id = ti_qty.transaction_id
    WHERE t.order_status = 'Completed'
    GROUP BY DATE_TRUNC('week', transaction_date)
)
SELECT
    week_start,
    total_orders,
    revenue,
    units_sold,
    -- 4-week moving average
    ROUND(AVG(revenue) OVER (
        ORDER BY week_start
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ), 2)                                                  AS revenue_4wk_avg,
    -- Week-over-week change
    revenue - LAG(revenue) OVER (ORDER BY week_start)    AS wow_change,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY week_start)) /
        NULLIF(LAG(revenue) OVER (ORDER BY week_start), 0) * 100
    , 2)                                                  AS wow_growth_pct,
    -- Running total
    SUM(revenue) OVER (ORDER BY week_start)              AS running_total
FROM weekly_sales
ORDER BY week_start;

-- ============================================================================
-- 4.4 Seasonal Pattern Detection
-- Identifies recurring patterns across months/quarters
-- ============================================================================
WITH monthly_metrics AS (
    SELECT
        EXTRACT(MONTH FROM transaction_date)::INTEGER    AS month_num,
        TO_CHAR(transaction_date, 'Month')               AS month_name,
        EXTRACT(YEAR FROM transaction_date)::INTEGER     AS year,
        SUM(total_amount)                                AS revenue,
        COUNT(DISTINCT transaction_id)                   AS orders,
        COUNT(DISTINCT customer_id)                      AS customers
    FROM transactions
    WHERE order_status = 'Completed'
    GROUP BY
        EXTRACT(MONTH FROM transaction_date),
        TO_CHAR(transaction_date, 'Month'),
        EXTRACT(YEAR FROM transaction_date)
),
seasonal AS (
    SELECT
        month_num,
        TRIM(month_name)                                  AS month_name,
        -- Average across years
        ROUND(AVG(revenue), 2)                            AS avg_revenue,
        ROUND(AVG(orders), 0)                             AS avg_orders,
        ROUND(AVG(customers), 0)                          AS avg_customers,
        -- Calculate seasonal index (month avg / overall monthly avg)
        ROUND(
            AVG(revenue) /
            NULLIF((SELECT AVG(total_amount_monthly)
                    FROM (SELECT SUM(total_amount) AS total_amount_monthly
                          FROM transactions
                          WHERE order_status = 'Completed'
                          GROUP BY DATE_TRUNC('month', transaction_date)) sub), 0)
        , 3)                                               AS seasonal_index,
        CASE
            WHEN month_num IN (11, 12) THEN 'Holiday Peak'
            WHEN month_num IN (6, 7) THEN 'Summer Peak'
            WHEN month_num IN (1, 2) THEN 'Post-Holiday Dip'
            WHEN month_num IN (3, 4, 5) THEN 'Spring Recovery'
            ELSE 'Steady State'
        END                                                AS season_label
    FROM monthly_metrics
    GROUP BY month_num, TRIM(month_name)
)
SELECT * FROM seasonal
ORDER BY month_num;

-- ============================================================================
-- 4.5 Daily Revenue with 7-Day and 30-Day Moving Averages
-- Uses RANGE/ROWS window frames
-- ============================================================================
WITH daily_revenue AS (
    SELECT
        DATE(transaction_date)                           AS sale_date,
        COUNT(DISTINCT transaction_id)                   AS orders,
        SUM(total_amount)                                AS revenue
    FROM transactions
    WHERE order_status = 'Completed'
    GROUP BY DATE(transaction_date)
)
SELECT
    sale_date,
    orders,
    revenue,
    -- 7-day moving average (trailing)
    ROUND(AVG(revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                                                  AS ma_7day,
    -- 30-day moving average (trailing)
    ROUND(AVG(revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2)                                                  AS ma_30day,
    -- Min and max in 7-day window
    MIN(revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                                                      AS min_7day,
    MAX(revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                                                      AS max_7day,
    -- Next day forecast (simple: use 7-day avg)
    LEAD(revenue) OVER (ORDER BY sale_date)              AS next_day_actual
FROM daily_revenue
ORDER BY sale_date DESC
LIMIT 90;

-- ============================================================================
-- 4.6 Quarter-over-Quarter Performance
-- ============================================================================
WITH quarterly AS (
    SELECT
        EXTRACT(YEAR FROM transaction_date)::INTEGER     AS year,
        EXTRACT(QUARTER FROM transaction_date)::INTEGER  AS quarter,
        'Q' || EXTRACT(QUARTER FROM transaction_date) || ' ' ||
            EXTRACT(YEAR FROM transaction_date)          AS quarter_label,
        COUNT(DISTINCT transaction_id)                   AS total_orders,
        SUM(total_amount)                                AS revenue,
        COUNT(DISTINCT customer_id)                      AS unique_customers,
        ROUND(AVG(total_amount), 2)                      AS avg_order_value
    FROM transactions
    WHERE order_status = 'Completed'
    GROUP BY
        EXTRACT(YEAR FROM transaction_date),
        EXTRACT(QUARTER FROM transaction_date)
)
SELECT
    quarter_label,
    total_orders,
    revenue,
    unique_customers,
    avg_order_value,
    LAG(revenue) OVER (ORDER BY year, quarter)           AS prev_quarter_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year, quarter)) /
        NULLIF(LAG(revenue) OVER (ORDER BY year, quarter), 0) * 100
    , 2)                                                  AS qoq_growth_pct,
    -- Cumulative revenue for the year
    SUM(revenue) OVER (
        PARTITION BY year
        ORDER BY quarter
    )                                                      AS ytd_revenue
FROM quarterly
ORDER BY year, quarter;
