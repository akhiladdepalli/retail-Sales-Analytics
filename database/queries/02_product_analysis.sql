-- ============================================================================
-- QUERY SET 2: PRODUCT ANALYSIS
-- Demonstrates: JOINs (INNER, LEFT, CROSS), Subqueries, RANK(), DENSE_RANK()
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- 2.1 Top 20 Products by Revenue (Multi-table JOIN)
-- ============================================================================
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    p.brand,
    p.unit_price,
    p.unit_cost,
    p.margin_pct,
    COUNT(DISTINCT ti.transaction_id)                 AS times_ordered,
    SUM(ti.quantity)                                  AS total_units_sold,
    SUM(ti.line_total)                               AS total_revenue,
    SUM(ti.quantity * p.unit_cost)                    AS total_cogs,
    SUM(ti.line_total) - SUM(ti.quantity * p.unit_cost) AS gross_profit,
    ROUND((SUM(ti.line_total) - SUM(ti.quantity * p.unit_cost))
          / NULLIF(SUM(ti.line_total), 0) * 100, 2)  AS actual_margin_pct,
    COUNT(DISTINCT t.customer_id)                    AS unique_buyers
FROM products p
INNER JOIN transaction_items ti ON p.product_id = ti.product_id
INNER JOIN transactions t ON ti.transaction_id = t.transaction_id
WHERE t.order_status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category, p.sub_category,
         p.brand, p.unit_price, p.unit_cost, p.margin_pct
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================================================
-- 2.2 Category Performance Summary with Ranking
-- ============================================================================
SELECT
    p.category,
    COUNT(DISTINCT p.product_id)                     AS product_count,
    COUNT(DISTINCT ti.transaction_id)                AS total_orders,
    SUM(ti.quantity)                                  AS total_units_sold,
    SUM(ti.line_total)                               AS total_revenue,
    ROUND(AVG(ti.line_total), 2)                     AS avg_line_value,
    ROUND(SUM(ti.line_total) / NULLIF(SUM(SUM(ti.line_total)) OVER (), 0) * 100, 2)
                                                      AS revenue_share_pct,
    RANK() OVER (ORDER BY SUM(ti.line_total) DESC)   AS revenue_rank,
    RANK() OVER (ORDER BY SUM(ti.quantity) DESC)     AS units_rank,
    SUM(ti.line_total) - SUM(ti.quantity * p.unit_cost) AS gross_profit,
    ROUND((SUM(ti.line_total) - SUM(ti.quantity * p.unit_cost))
          / NULLIF(SUM(ti.line_total), 0) * 100, 2)  AS margin_pct
FROM products p
INNER JOIN transaction_items ti ON p.product_id = ti.product_id
INNER JOIN transactions t ON ti.transaction_id = t.transaction_id
WHERE t.order_status = 'Completed'
GROUP BY p.category
ORDER BY revenue_rank;

-- ============================================================================
-- 2.3 Top 3 Products per Category (DENSE_RANK with PARTITION BY)
-- ============================================================================
WITH product_revenue AS (
    SELECT
        p.category,
        p.product_name,
        p.brand,
        SUM(ti.line_total)                            AS total_revenue,
        SUM(ti.quantity)                              AS total_units,
        DENSE_RANK() OVER (
            PARTITION BY p.category
            ORDER BY SUM(ti.line_total) DESC
        )                                              AS rank_in_category
    FROM products p
    INNER JOIN transaction_items ti ON p.product_id = ti.product_id
    INNER JOIN transactions t ON ti.transaction_id = t.transaction_id
    WHERE t.order_status = 'Completed'
    GROUP BY p.category, p.product_name, p.brand
)
SELECT
    category,
    rank_in_category,
    product_name,
    brand,
    total_revenue,
    total_units
FROM product_revenue
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;

-- ============================================================================
-- 2.4 Products with NO Sales (LEFT JOIN to find gaps)
-- ============================================================================
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.unit_price,
    p.launch_date,
    CURRENT_DATE - p.launch_date                     AS days_since_launch
FROM products p
LEFT JOIN transaction_items ti ON p.product_id = ti.product_id
LEFT JOIN transactions t ON ti.transaction_id = t.transaction_id
    AND t.order_status = 'Completed'
WHERE t.transaction_id IS NULL
ORDER BY p.launch_date;

-- ============================================================================
-- 2.5 Brand Performance Analysis with Market Share
-- ============================================================================
SELECT
    p.brand,
    p.category,
    COUNT(DISTINCT p.product_id)                     AS products_in_catalog,
    SUM(ti.quantity)                                  AS total_units_sold,
    SUM(ti.line_total)                               AS total_revenue,
    ROUND(AVG(p.unit_price), 2)                      AS avg_price_point,
    ROUND(AVG(p.margin_pct), 2)                      AS avg_margin_pct,
    -- Market share within category
    ROUND(SUM(ti.line_total) * 100.0 /
        NULLIF(SUM(SUM(ti.line_total)) OVER (PARTITION BY p.category), 0), 2)
                                                      AS category_market_share_pct,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(ti.line_total) DESC
    )                                                  AS brand_rank_in_category
FROM products p
INNER JOIN transaction_items ti ON p.product_id = ti.product_id
INNER JOIN transactions t ON ti.transaction_id = t.transaction_id
WHERE t.order_status = 'Completed'
GROUP BY p.brand, p.category
ORDER BY p.category, brand_rank_in_category;

-- ============================================================================
-- 2.6 Price Elasticity Analysis — Revenue vs Price Buckets (Subquery)
-- ============================================================================
SELECT
    price_bucket,
    product_count,
    total_units_sold,
    total_revenue,
    ROUND(total_revenue / NULLIF(product_count, 0), 2) AS avg_revenue_per_product,
    ROUND(total_units_sold::NUMERIC / NULLIF(product_count, 0), 1) AS avg_units_per_product,
    ROUND(total_revenue * 100.0 / NULLIF(SUM(total_revenue) OVER (), 0), 2)
                                                        AS revenue_share_pct
FROM (
    SELECT
        CASE
            WHEN p.unit_price < 25 THEN 'Under $25'
            WHEN p.unit_price < 50 THEN '$25-$49'
            WHEN p.unit_price < 100 THEN '$50-$99'
            WHEN p.unit_price < 250 THEN '$100-$249'
            WHEN p.unit_price < 500 THEN '$250-$499'
            WHEN p.unit_price < 1000 THEN '$500-$999'
            ELSE '$1000+'
        END                                            AS price_bucket,
        CASE
            WHEN p.unit_price < 25 THEN 1
            WHEN p.unit_price < 50 THEN 2
            WHEN p.unit_price < 100 THEN 3
            WHEN p.unit_price < 250 THEN 4
            WHEN p.unit_price < 500 THEN 5
            WHEN p.unit_price < 1000 THEN 6
            ELSE 7
        END                                            AS bucket_order,
        COUNT(DISTINCT p.product_id)                   AS product_count,
        COALESCE(SUM(ti.quantity), 0)                  AS total_units_sold,
        COALESCE(SUM(ti.line_total), 0)                AS total_revenue
    FROM products p
    LEFT JOIN transaction_items ti ON p.product_id = ti.product_id
    LEFT JOIN transactions t ON ti.transaction_id = t.transaction_id
        AND t.order_status = 'Completed'
    GROUP BY
        CASE
            WHEN p.unit_price < 25 THEN 'Under $25'
            WHEN p.unit_price < 50 THEN '$25-$49'
            WHEN p.unit_price < 100 THEN '$50-$99'
            WHEN p.unit_price < 250 THEN '$100-$249'
            WHEN p.unit_price < 500 THEN '$250-$499'
            WHEN p.unit_price < 1000 THEN '$500-$999'
            ELSE '$1000+'
        END,
        CASE
            WHEN p.unit_price < 25 THEN 1
            WHEN p.unit_price < 50 THEN 2
            WHEN p.unit_price < 100 THEN 3
            WHEN p.unit_price < 250 THEN 4
            WHEN p.unit_price < 500 THEN 5
            WHEN p.unit_price < 1000 THEN 6
            ELSE 7
        END
) sub
ORDER BY bucket_order;
