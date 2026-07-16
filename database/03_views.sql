-- ============================================================================
-- RETAIL SALES ANALYTICS — MATERIALIZED VIEWS
-- Pre-computed analytics views for dashboard consumption
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- VIEW 1: DAILY SALES SUMMARY
-- Aggregated daily metrics for time-series analysis
-- ============================================================================
CREATE MATERIALIZED VIEW v_daily_sales_summary AS
WITH daily_metrics AS (
    SELECT
        DATE(t.transaction_date)                    AS sale_date,
        EXTRACT(YEAR FROM t.transaction_date)       AS sale_year,
        EXTRACT(MONTH FROM t.transaction_date)      AS sale_month,
        EXTRACT(DOW FROM t.transaction_date)        AS day_of_week,
        TO_CHAR(t.transaction_date, 'Day')          AS day_name,
        s.region,
        s.store_type,
        COUNT(DISTINCT t.transaction_id)            AS total_orders,
        COUNT(DISTINCT t.customer_id)               AS unique_customers,
        SUM(t.total_amount)                         AS total_revenue,
        SUM(t.subtotal)                             AS gross_revenue,
        SUM(t.discount_amount)                      AS total_discounts,
        SUM(t.tax_amount)                           AS total_tax,
        ROUND(AVG(t.total_amount), 2)               AS avg_order_value,
        SUM(ti.quantity)                            AS total_units_sold,
        COUNT(DISTINCT ti.product_id)               AS unique_products_sold
    FROM transactions t
    JOIN stores s ON t.store_id = s.store_id
    JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
    WHERE t.order_status = 'Completed'
    GROUP BY
        DATE(t.transaction_date),
        EXTRACT(YEAR FROM t.transaction_date),
        EXTRACT(MONTH FROM t.transaction_date),
        EXTRACT(DOW FROM t.transaction_date),
        TO_CHAR(t.transaction_date, 'Day'),
        s.region,
        s.store_type
)
SELECT * FROM daily_metrics
ORDER BY sale_date DESC;

-- Index for fast date-range queries
CREATE UNIQUE INDEX idx_v_daily_sales_date_region
    ON v_daily_sales_summary(sale_date, region, store_type);

-- ============================================================================
-- VIEW 2: PRODUCT PERFORMANCE
-- Product-level KPIs with category rankings
-- ============================================================================
CREATE MATERIALIZED VIEW v_product_performance AS
WITH product_stats AS (
    SELECT
        p.product_id,
        p.product_name,
        p.sku,
        p.category,
        p.sub_category,
        p.brand,
        p.unit_price                                AS current_price,
        p.unit_cost,
        p.margin_pct                                AS standard_margin,
        COUNT(DISTINCT ti.transaction_id)           AS times_ordered,
        SUM(ti.quantity)                            AS total_units_sold,
        SUM(ti.line_total)                          AS total_revenue,
        ROUND(AVG(ti.line_total), 2)                AS avg_line_total,
        ROUND(AVG(ti.discount_pct), 2)              AS avg_discount_given,
        SUM(ti.quantity * p.unit_cost)               AS total_cost,
        SUM(ti.line_total) - SUM(ti.quantity * p.unit_cost) AS gross_profit,
        COUNT(DISTINCT t.customer_id)               AS unique_buyers,
        MIN(t.transaction_date)                     AS first_sale_date,
        MAX(t.transaction_date)                     AS last_sale_date
    FROM products p
    LEFT JOIN transaction_items ti ON p.product_id = ti.product_id
    LEFT JOIN transactions t ON ti.transaction_id = t.transaction_id
        AND t.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name, p.sku, p.category,
             p.sub_category, p.brand, p.unit_price, p.unit_cost, p.margin_pct
),
ranked AS (
    SELECT
        ps.*,
        ROUND((gross_profit / NULLIF(total_revenue, 0)) * 100, 2) AS actual_margin_pct,
        RANK() OVER (ORDER BY total_revenue DESC)                   AS revenue_rank_overall,
        RANK() OVER (PARTITION BY category ORDER BY total_revenue DESC) AS revenue_rank_category,
        RANK() OVER (ORDER BY total_units_sold DESC)               AS units_rank_overall,
        PERCENT_RANK() OVER (ORDER BY total_revenue)               AS revenue_percentile,
        SUM(total_revenue) OVER ()                                 AS grand_total_revenue,
        ROUND(total_revenue / NULLIF(SUM(total_revenue) OVER (), 0) * 100, 4)
                                                                    AS revenue_contribution_pct
    FROM product_stats ps
)
SELECT * FROM ranked
ORDER BY revenue_rank_overall;

CREATE UNIQUE INDEX idx_v_product_perf_id ON v_product_performance(product_id);

-- ============================================================================
-- VIEW 3: CUSTOMER 360° PROFILE
-- Comprehensive customer metrics including RFM scoring
-- ============================================================================
CREATE MATERIALIZED VIEW v_customer_360 AS
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name          AS full_name,
        c.email,
        c.city,
        c.state,
        c.loyalty_tier,
        c.join_date,
        c.is_active,
        COUNT(DISTINCT t.transaction_id)             AS total_orders,
        SUM(t.total_amount)                          AS lifetime_value,
        ROUND(AVG(t.total_amount), 2)                AS avg_order_value,
        MIN(t.transaction_date)                      AS first_purchase_date,
        MAX(t.transaction_date)                      AS last_purchase_date,
        EXTRACT(DAY FROM NOW() - MAX(t.transaction_date))::INTEGER AS days_since_last_purchase,
        SUM(ti.quantity)                             AS total_items_purchased,
        COUNT(DISTINCT ti.product_id)                AS unique_products_bought,
        COUNT(DISTINCT p.category)                   AS categories_shopped,
        MODE() WITHIN GROUP (ORDER BY t.payment_method) AS preferred_payment,
        MODE() WITHIN GROUP (ORDER BY s.store_name)  AS preferred_store,
        COUNT(DISTINCT t.store_id)                   AS stores_visited
    FROM customers c
    LEFT JOIN transactions t ON c.customer_id = t.customer_id
        AND t.order_status = 'Completed'
    LEFT JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
    LEFT JOIN products p ON ti.product_id = p.product_id
    LEFT JOIN stores s ON t.store_id = s.store_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email,
             c.city, c.state, c.loyalty_tier, c.join_date, c.is_active
),
rfm_scores AS (
    SELECT
        cm.*,
        -- RFM Scoring using NTILE (1-5, 5 being best)
        NTILE(5) OVER (ORDER BY days_since_last_purchase DESC)  AS recency_score,
        NTILE(5) OVER (ORDER BY total_orders)                    AS frequency_score,
        NTILE(5) OVER (ORDER BY lifetime_value)                  AS monetary_score
    FROM customer_metrics cm
    WHERE total_orders > 0
),
segmented AS (
    SELECT
        rfm.*,
        recency_score + frequency_score + monetary_score AS rfm_total,
        CASE
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
            WHEN recency_score >= 3 AND frequency_score >= 2 AND monetary_score >= 2 THEN 'Potential Loyalists'
            WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'At Risk'
            WHEN recency_score <= 2 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Cannot Lose Them'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Hibernating'
            ELSE 'Need Attention'
        END AS customer_segment
    FROM rfm_scores
)
SELECT * FROM segmented
ORDER BY lifetime_value DESC;

CREATE UNIQUE INDEX idx_v_customer_360_id ON v_customer_360(customer_id);

-- ============================================================================
-- VIEW 4: STORE DASHBOARD
-- Store-level performance metrics with regional benchmarking
-- ============================================================================
CREATE MATERIALIZED VIEW v_store_dashboard AS
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
        s.opened_date,
        s.manager_name,
        COUNT(DISTINCT t.transaction_id)             AS total_transactions,
        COUNT(DISTINCT t.customer_id)                AS unique_customers,
        SUM(t.total_amount)                          AS total_revenue,
        SUM(t.subtotal)                              AS gross_revenue,
        SUM(t.discount_amount)                       AS total_discounts,
        ROUND(AVG(t.total_amount), 2)                AS avg_transaction_value,
        SUM(ti.quantity)                             AS total_units_sold,
        COUNT(DISTINCT ti.product_id)                AS unique_products_sold,
        COUNT(DISTINCT p.category)                   AS categories_sold,
        ROUND(SUM(t.total_amount) / NULLIF(s.square_footage, 0), 2) AS revenue_per_sqft
    FROM stores s
    LEFT JOIN transactions t ON s.store_id = t.store_id
        AND t.order_status = 'Completed'
    LEFT JOIN transaction_items ti ON t.transaction_id = ti.transaction_id
    LEFT JOIN products p ON ti.product_id = p.product_id
    GROUP BY s.store_id, s.store_name, s.store_code, s.store_type,
             s.city, s.state, s.region, s.square_footage, s.opened_date, s.manager_name
),
regional_benchmarks AS (
    SELECT
        sm.*,
        -- Regional averages for benchmarking
        ROUND(AVG(total_revenue) OVER (PARTITION BY region), 2)        AS region_avg_revenue,
        ROUND(AVG(avg_transaction_value) OVER (PARTITION BY region), 2) AS region_avg_txn_value,
        ROUND(AVG(unique_customers) OVER (PARTITION BY region), 0)     AS region_avg_customers,
        -- Rankings
        RANK() OVER (ORDER BY total_revenue DESC)                       AS revenue_rank,
        RANK() OVER (PARTITION BY region ORDER BY total_revenue DESC)   AS region_revenue_rank,
        RANK() OVER (ORDER BY revenue_per_sqft DESC NULLS LAST)        AS efficiency_rank,
        -- Percentage of total
        ROUND(total_revenue / NULLIF(SUM(total_revenue) OVER (), 0) * 100, 2) AS revenue_share_pct
    FROM store_metrics sm
)
SELECT * FROM regional_benchmarks
ORDER BY revenue_rank;

CREATE UNIQUE INDEX idx_v_store_dashboard_id ON v_store_dashboard(store_id);

-- ============================================================================
-- REFRESH FUNCTION — Call periodically to update materialized views
-- ============================================================================
CREATE OR REPLACE FUNCTION refresh_analytics_views()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_daily_sales_summary;
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_product_performance;
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_customer_360;
    REFRESH MATERIALIZED VIEW CONCURRENTLY v_store_dashboard;
    RAISE NOTICE 'All analytics views refreshed at %', NOW();
END;
$$ LANGUAGE plpgsql;
