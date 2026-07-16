-- ============================================================================
-- QUERY SET 5: STORE PERFORMANCE & REGIONAL ANALYSIS
-- Demonstrates: PARTITION BY, CROSS JOIN, Benchmarking, Percentiles
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- 5.1 Store Performance Scorecard
-- Complete store metrics with regional benchmarking
-- ============================================================================
WITH store_metrics AS (
    SELECT
        s.store_id,
        s.store_name,
        s.store_code,
        s.store_type,
        s.city,
        s.state,
        s.region,
        s.square_footage,
        s.manager_name,
        COUNT(DISTINCT t.transaction_id)                 AS total_transactions,
        COUNT(DISTINCT t.customer_id)                    AS unique_customers,
        SUM(t.total_amount)                              AS total_revenue,
        SUM(t.discount_amount)                           AS total_discounts,
        ROUND(AVG(t.total_amount), 2)                    AS avg_transaction_value,
        SUM(ti.quantity)                                 AS total_units_sold,
        COUNT(DISTINCT ti.product_id)                    AS unique_products_sold,
        -- Revenue per square foot
        ROUND(SUM(t.total_amount) / NULLIF(s.square_footage, 0), 2)
                                                          AS revenue_per_sqft
    FROM stores s
    LEFT JOIN transactions t ON s.store_id = t.store_id
        AND t.order_status = 'Completed'
    LEFT JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
    GROUP BY s.store_id, s.store_name, s.store_code, s.store_type,
             s.city, s.state, s.region, s.square_footage, s.manager_name
)
SELECT
    sm.*,
    -- Regional benchmarks using window functions
    ROUND(AVG(total_revenue) OVER (PARTITION BY region), 2)
                                                          AS region_avg_revenue,
    ROUND(AVG(avg_transaction_value) OVER (PARTITION BY region), 2)
                                                          AS region_avg_txn_value,
    -- Performance vs regional average
    ROUND(
        (total_revenue - AVG(total_revenue) OVER (PARTITION BY region)) /
        NULLIF(AVG(total_revenue) OVER (PARTITION BY region), 0) * 100
    , 2)                                                  AS pct_vs_region_avg,
    -- Rankings
    RANK() OVER (ORDER BY total_revenue DESC)            AS overall_revenue_rank,
    RANK() OVER (PARTITION BY region ORDER BY total_revenue DESC)
                                                          AS region_revenue_rank,
    RANK() OVER (ORDER BY revenue_per_sqft DESC NULLS LAST)
                                                          AS efficiency_rank,
    -- Revenue share
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2)
                                                          AS revenue_share_pct
FROM store_metrics sm
ORDER BY total_revenue DESC;

-- ============================================================================
-- 5.2 Regional Performance Summary
-- ============================================================================
SELECT
    s.region,
    COUNT(DISTINCT s.store_id)                           AS store_count,
    COUNT(DISTINCT t.transaction_id)                     AS total_transactions,
    COUNT(DISTINCT t.customer_id)                        AS unique_customers,
    SUM(t.total_amount)                                  AS total_revenue,
    ROUND(AVG(t.total_amount), 2)                        AS avg_order_value,
    SUM(t.discount_amount)                               AS total_discounts,
    -- Per-store averages
    ROUND(SUM(t.total_amount) / COUNT(DISTINCT s.store_id), 2)
                                                          AS avg_revenue_per_store,
    ROUND(COUNT(DISTINCT t.customer_id)::NUMERIC / COUNT(DISTINCT s.store_id), 0)
                                                          AS avg_customers_per_store,
    -- Revenue rank
    RANK() OVER (ORDER BY SUM(t.total_amount) DESC)      AS region_rank
FROM stores s
LEFT JOIN transactions t ON s.store_id = t.store_id
    AND t.order_status = 'Completed'
GROUP BY s.region
ORDER BY total_revenue DESC;

-- ============================================================================
-- 5.3 Store Type Performance Comparison
-- Flagship vs Standard vs Outlet vs Express
-- ============================================================================
WITH type_metrics AS (
    SELECT
        s.store_type,
        COUNT(DISTINCT s.store_id)                       AS store_count,
        AVG(s.square_footage)                            AS avg_sqft,
        COUNT(DISTINCT t.transaction_id)                 AS total_orders,
        SUM(t.total_amount)                              AS total_revenue,
        ROUND(AVG(t.total_amount), 2)                    AS avg_order_value,
        ROUND(SUM(t.total_amount) / COUNT(DISTINCT s.store_id), 2)
                                                          AS revenue_per_store,
        COUNT(DISTINCT t.customer_id)                    AS unique_customers,
        -- Average discount rate
        ROUND(SUM(t.discount_amount) / NULLIF(SUM(t.subtotal), 0) * 100, 2)
                                                          AS avg_discount_rate
    FROM stores s
    LEFT JOIN transactions t ON s.store_id = t.store_id
        AND t.order_status = 'Completed'
    GROUP BY s.store_type
)
SELECT
    store_type,
    store_count,
    ROUND(avg_sqft, 0)                                   AS avg_sqft,
    total_orders,
    total_revenue,
    avg_order_value,
    revenue_per_store,
    unique_customers,
    avg_discount_rate,
    -- Revenue efficiency: revenue per sqft per store
    ROUND(total_revenue / NULLIF(SUM(avg_sqft * store_count) OVER (), 0) * 10000, 2)
                                                          AS normalized_efficiency,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2)
                                                          AS revenue_share_pct
FROM type_metrics
ORDER BY total_revenue DESC;

-- ============================================================================
-- 5.4 Store Monthly Trend Comparison
-- Track each store's performance over time
-- ============================================================================
WITH store_monthly AS (
    SELECT
        s.store_name,
        s.region,
        DATE_TRUNC('month', t.transaction_date)::DATE    AS month,
        SUM(t.total_amount)                              AS monthly_revenue,
        COUNT(DISTINCT t.transaction_id)                 AS monthly_orders,
        COUNT(DISTINCT t.customer_id)                    AS monthly_customers
    FROM stores s
    INNER JOIN transactions t ON s.store_id = t.store_id
    WHERE t.order_status = 'Completed'
    GROUP BY s.store_name, s.region, DATE_TRUNC('month', t.transaction_date)
)
SELECT
    store_name,
    region,
    TO_CHAR(month, 'YYYY-MM')                            AS month,
    monthly_revenue,
    monthly_orders,
    monthly_customers,
    -- Month-over-month for each store
    LAG(monthly_revenue) OVER (PARTITION BY store_name ORDER BY month)
                                                          AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (PARTITION BY store_name ORDER BY month)) /
        NULLIF(LAG(monthly_revenue) OVER (PARTITION BY store_name ORDER BY month), 0) * 100
    , 2)                                                  AS mom_growth_pct,
    -- Store's share of regional revenue that month
    ROUND(
        monthly_revenue * 100.0 /
        SUM(monthly_revenue) OVER (PARTITION BY region, month)
    , 2)                                                  AS regional_share_pct
FROM store_monthly
ORDER BY store_name, month;

-- ============================================================================
-- 5.5 Cross-Store Product Category Mix
-- Which categories sell best at which stores?
-- ============================================================================
WITH store_category AS (
    SELECT
        s.store_name,
        s.store_type,
        s.region,
        p.category,
        SUM(ti.line_total)                               AS category_revenue,
        SUM(ti.quantity)                                  AS units_sold,
        COUNT(DISTINCT t.transaction_id)                 AS order_count
    FROM stores s
    INNER JOIN transactions t ON s.store_id = t.store_id
    INNER JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
    INNER JOIN products p ON ti.product_id = p.product_id
    WHERE t.order_status = 'Completed'
    GROUP BY s.store_name, s.store_type, s.region, p.category
)
SELECT
    store_name,
    store_type,
    region,
    category,
    category_revenue,
    units_sold,
    -- Category share within this store
    ROUND(
        category_revenue * 100.0 /
        SUM(category_revenue) OVER (PARTITION BY store_name)
    , 2)                                                  AS pct_of_store_revenue,
    -- Rank of this category within the store
    RANK() OVER (PARTITION BY store_name ORDER BY category_revenue DESC)
                                                          AS category_rank,
    -- Compare to chain-wide average for this category
    ROUND(
        category_revenue /
        NULLIF(AVG(category_revenue) OVER (PARTITION BY category), 0) * 100
    , 2)                                                  AS vs_chain_avg_pct
FROM store_category
ORDER BY store_name, category_rank;

-- ============================================================================
-- 5.6 Store-to-Store Customer Overlap Analysis (CROSS JOIN)
-- How many customers shop at multiple stores?
-- ============================================================================
WITH store_customers AS (
    SELECT DISTINCT
        t.store_id,
        s.store_name,
        t.customer_id
    FROM transactions t
    INNER JOIN stores s ON t.store_id = s.store_id
    WHERE t.order_status = 'Completed'
)
SELECT
    a.store_name AS store_a,
    b.store_name AS store_b,
    COUNT(DISTINCT a.customer_id) AS shared_customers,
    -- Percentage of store A's customers who also shop at store B
    ROUND(
        COUNT(DISTINCT a.customer_id) * 100.0 /
        NULLIF((SELECT COUNT(DISTINCT customer_id) FROM store_customers WHERE store_name = a.store_name), 0)
    , 2) AS pct_of_store_a
FROM store_customers a
INNER JOIN store_customers b
    ON a.customer_id = b.customer_id
    AND a.store_id < b.store_id  -- Avoid duplicates & self-joins
GROUP BY a.store_name, b.store_name
HAVING COUNT(DISTINCT a.customer_id) > 0
ORDER BY shared_customers DESC;
