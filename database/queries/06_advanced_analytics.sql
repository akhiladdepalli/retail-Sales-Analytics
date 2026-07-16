-- ============================================================================
-- QUERY SET 6: ADVANCED ANALYTICS
-- Demonstrates: Recursive CTEs, LATERAL joins, Cohort Analysis,
--               Market Basket Analysis, Running Totals
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- 6.1 COHORT RETENTION ANALYSIS
-- Tracks how well each monthly cohort retains over subsequent months
-- Uses: CTE chaining, DATE arithmetic, CROSS JOIN for cohort grid
-- ============================================================================
WITH cohort_base AS (
    -- Determine each customer's first purchase month (cohort month)
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(transaction_date))::DATE AS cohort_month
    FROM transactions
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
activity AS (
    -- For each customer, get all months they were active
    SELECT DISTINCT
        t.customer_id,
        cb.cohort_month,
        DATE_TRUNC('month', t.transaction_date)::DATE    AS activity_month,
        -- Month index: 0 = cohort month, 1 = next month, etc.
        (EXTRACT(YEAR FROM DATE_TRUNC('month', t.transaction_date)) * 12 +
         EXTRACT(MONTH FROM DATE_TRUNC('month', t.transaction_date))) -
        (EXTRACT(YEAR FROM cb.cohort_month) * 12 +
         EXTRACT(MONTH FROM cb.cohort_month))             AS month_index
    FROM transactions t
    INNER JOIN cohort_base cb ON t.customer_id = cb.customer_id
    WHERE t.order_status = 'Completed'
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_base
    GROUP BY cohort_month
),
retention AS (
    SELECT
        a.cohort_month,
        a.month_index,
        COUNT(DISTINCT a.customer_id)                    AS active_customers,
        cs.cohort_size,
        ROUND(
            COUNT(DISTINCT a.customer_id) * 100.0 / cs.cohort_size
        , 2)                                              AS retention_rate
    FROM activity a
    INNER JOIN cohort_sizes cs ON a.cohort_month = cs.cohort_month
    WHERE a.month_index <= 12  -- First 12 months
    GROUP BY a.cohort_month, a.month_index, cs.cohort_size
)
SELECT
    TO_CHAR(cohort_month, 'YYYY-MM')                     AS cohort,
    cohort_size,
    month_index,
    active_customers,
    retention_rate
FROM retention
WHERE cohort_month >= '2024-01-01'
ORDER BY cohort_month, month_index;

-- ============================================================================
-- 6.2 MARKET BASKET ANALYSIS
-- Find products frequently bought together
-- Uses: Self-join, Aggregation, Support/Confidence metrics
-- ============================================================================
WITH basket_pairs AS (
    -- Find all pairs of products in the same transaction
    SELECT
        a.product_id AS product_a,
        b.product_id AS product_b,
        COUNT(DISTINCT a.transaction_id)                 AS pair_count
    FROM transaction_items a
    INNER JOIN transaction_items b
        ON a.transaction_id = b.transaction_id
        AND a.product_id < b.product_id  -- Avoid duplicates
    INNER JOIN transactions t
        ON a.transaction_id = t.transaction_id
    WHERE t.order_status = 'Completed'
    GROUP BY a.product_id, b.product_id
    HAVING COUNT(DISTINCT a.transaction_id) >= 5  -- Minimum support threshold
),
product_counts AS (
    SELECT
        ti.product_id,
        COUNT(DISTINCT ti.transaction_id) AS transaction_count
    FROM transaction_items ti
    INNER JOIN transactions t ON ti.transaction_id = t.transaction_id
    WHERE t.order_status = 'Completed'
    GROUP BY ti.product_id
),
total_transactions AS (
    SELECT COUNT(DISTINCT transaction_id) AS total
    FROM transactions
    WHERE order_status = 'Completed'
)
SELECT
    pa.product_name                                      AS product_a_name,
    pa.category                                          AS product_a_category,
    pb.product_name                                      AS product_b_name,
    pb.category                                          AS product_b_category,
    bp.pair_count,
    -- Support: How often this pair appears in all transactions
    ROUND(bp.pair_count * 100.0 / tt.total, 4)           AS support_pct,
    -- Confidence A→B: Given A is bought, probability B is also bought
    ROUND(bp.pair_count * 100.0 / pca.transaction_count, 2)
                                                          AS confidence_a_to_b,
    -- Confidence B→A
    ROUND(bp.pair_count * 100.0 / pcb.transaction_count, 2)
                                                          AS confidence_b_to_a,
    -- Lift: How much more likely A and B are bought together vs independently
    ROUND(
        (bp.pair_count::NUMERIC / tt.total) /
        NULLIF((pca.transaction_count::NUMERIC / tt.total) *
               (pcb.transaction_count::NUMERIC / tt.total), 0)
    , 3)                                                  AS lift
FROM basket_pairs bp
INNER JOIN products pa ON bp.product_a = pa.product_id
INNER JOIN products pb ON bp.product_b = pb.product_id
INNER JOIN product_counts pca ON bp.product_a = pca.product_id
INNER JOIN product_counts pcb ON bp.product_b = pcb.product_id
CROSS JOIN total_transactions tt
ORDER BY lift DESC
LIMIT 30;

-- ============================================================================
-- 6.3 CUSTOMER PURCHASE VELOCITY
-- Uses LEAD() to calculate inter-purchase intervals
-- ============================================================================
WITH purchase_sequence AS (
    SELECT
        customer_id,
        transaction_id,
        transaction_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id ORDER BY transaction_date
        )                                                  AS purchase_number,
        LEAD(transaction_date) OVER (
            PARTITION BY customer_id ORDER BY transaction_date
        )                                                  AS next_purchase_date,
        LEAD(total_amount) OVER (
            PARTITION BY customer_id ORDER BY transaction_date
        )                                                  AS next_purchase_amount
    FROM transactions
    WHERE order_status = 'Completed'
),
intervals AS (
    SELECT
        customer_id,
        purchase_number,
        transaction_date,
        next_purchase_date,
        total_amount,
        EXTRACT(DAY FROM next_purchase_date - transaction_date)::INTEGER
                                                          AS days_to_next_purchase
    FROM purchase_sequence
    WHERE next_purchase_date IS NOT NULL
)
SELECT
    CASE
        WHEN days_to_next_purchase <= 7 THEN '0-7 days'
        WHEN days_to_next_purchase <= 14 THEN '8-14 days'
        WHEN days_to_next_purchase <= 30 THEN '15-30 days'
        WHEN days_to_next_purchase <= 60 THEN '31-60 days'
        WHEN days_to_next_purchase <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END                                                   AS purchase_interval,
    COUNT(*)                                              AS occurrence_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS pct_of_total,
    ROUND(AVG(total_amount), 2)                           AS avg_order_value,
    COUNT(DISTINCT customer_id)                           AS unique_customers
FROM intervals
GROUP BY
    CASE
        WHEN days_to_next_purchase <= 7 THEN '0-7 days'
        WHEN days_to_next_purchase <= 14 THEN '8-14 days'
        WHEN days_to_next_purchase <= 30 THEN '15-30 days'
        WHEN days_to_next_purchase <= 60 THEN '31-60 days'
        WHEN days_to_next_purchase <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END
ORDER BY
    CASE
        WHEN days_to_next_purchase <= 7 THEN 1
        WHEN days_to_next_purchase <= 14 THEN 2
        WHEN days_to_next_purchase <= 30 THEN 3
        WHEN days_to_next_purchase <= 60 THEN 4
        WHEN days_to_next_purchase <= 90 THEN 5
        ELSE 6
    END;

-- ============================================================================
-- 6.4 RUNNING REVENUE MILESTONES
-- Track when each store hit revenue milestones ($100K, $250K, $500K, $1M)
-- Uses: Running sum with window function, LATERAL join concept
-- ============================================================================
WITH store_running AS (
    SELECT
        s.store_name,
        t.transaction_date,
        t.total_amount,
        SUM(t.total_amount) OVER (
            PARTITION BY s.store_id
            ORDER BY t.transaction_date
        )                                                  AS running_revenue
    FROM stores s
    INNER JOIN transactions t ON s.store_id = t.store_id
    WHERE t.order_status = 'Completed'
),
milestones AS (
    SELECT
        store_name,
        MIN(CASE WHEN running_revenue >= 100000 THEN transaction_date END)   AS milestone_100k,
        MIN(CASE WHEN running_revenue >= 250000 THEN transaction_date END)   AS milestone_250k,
        MIN(CASE WHEN running_revenue >= 500000 THEN transaction_date END)   AS milestone_500k,
        MIN(CASE WHEN running_revenue >= 1000000 THEN transaction_date END)  AS milestone_1m,
        MAX(running_revenue)                                                  AS current_total_revenue
    FROM store_running
    GROUP BY store_name
)
SELECT
    store_name,
    TO_CHAR(milestone_100k, 'YYYY-MM-DD')                AS hit_100k,
    TO_CHAR(milestone_250k, 'YYYY-MM-DD')                AS hit_250k,
    TO_CHAR(milestone_500k, 'YYYY-MM-DD')                AS hit_500k,
    TO_CHAR(milestone_1m, 'YYYY-MM-DD')                  AS hit_1m,
    ROUND(current_total_revenue, 2)                      AS total_revenue,
    -- Days from $100K to $250K
    EXTRACT(DAY FROM milestone_250k - milestone_100k)::INTEGER AS days_100k_to_250k,
    -- Days from $250K to $500K
    EXTRACT(DAY FROM milestone_500k - milestone_250k)::INTEGER AS days_250k_to_500k
FROM milestones
ORDER BY current_total_revenue DESC;

-- ============================================================================
-- 6.5 PARETO ANALYSIS (80/20 Rule)
-- Which products account for 80% of revenue?
-- Uses: Running percentage with window function
-- ============================================================================
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(ti.line_total) AS revenue
    FROM products p
    INNER JOIN transaction_items ti ON p.product_id = ti.product_id
    INNER JOIN transactions t ON ti.transaction_id = t.transaction_id
    WHERE t.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name, p.category
),
cumulative AS (
    SELECT
        product_name,
        category,
        revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC)       AS cumulative_revenue,
        SUM(revenue) OVER ()                             AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC)        AS rank,
        COUNT(*) OVER ()                                 AS total_products,
        ROUND(
            SUM(revenue) OVER (ORDER BY revenue DESC) * 100.0 /
            SUM(revenue) OVER ()
        , 2)                                              AS cumulative_pct,
        ROUND(
            ROW_NUMBER() OVER (ORDER BY revenue DESC) * 100.0 /
            COUNT(*) OVER ()
        , 2)                                              AS products_pct
    FROM product_revenue
)
SELECT
    rank,
    product_name,
    category,
    revenue,
    cumulative_revenue,
    cumulative_pct,
    products_pct,
    CASE
        WHEN cumulative_pct <= 50 THEN 'Top Tier (0-50%)'
        WHEN cumulative_pct <= 80 THEN 'Mid Tier (50-80%)'
        ELSE 'Long Tail (80-100%)'
    END AS pareto_tier
FROM cumulative
ORDER BY rank;

-- ============================================================================
-- 6.6 RECURSIVE CTE — Date Gap Analysis
-- Generate a continuous date series and identify days with no sales
-- ============================================================================
WITH RECURSIVE date_series AS (
    -- Anchor: first transaction date
    SELECT MIN(DATE(transaction_date)) AS dt
    FROM transactions
    UNION ALL
    -- Recurse: add 1 day until last transaction date
    SELECT dt + INTERVAL '1 day'
    FROM date_series
    WHERE dt < (SELECT MAX(DATE(transaction_date)) FROM transactions)
),
daily_sales AS (
    SELECT
        DATE(transaction_date) AS sale_date,
        COUNT(*) AS order_count,
        SUM(total_amount) AS revenue
    FROM transactions
    WHERE order_status = 'Completed'
    GROUP BY DATE(transaction_date)
)
SELECT
    ds.dt::DATE AS date,
    COALESCE(d.order_count, 0) AS orders,
    COALESCE(d.revenue, 0) AS revenue,
    CASE WHEN d.sale_date IS NULL THEN 'NO SALES' ELSE 'Active' END AS status,
    TO_CHAR(ds.dt, 'Day') AS day_name,
    EXTRACT(DOW FROM ds.dt) AS day_of_week
FROM date_series ds
LEFT JOIN daily_sales d ON ds.dt::DATE = d.sale_date
WHERE d.sale_date IS NULL  -- Only show gap days
ORDER BY ds.dt;
