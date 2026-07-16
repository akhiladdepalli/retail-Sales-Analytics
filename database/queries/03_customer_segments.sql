-- ============================================================================
-- QUERY SET 3: CUSTOMER SEGMENTATION & RFM ANALYSIS
-- Demonstrates: CTEs, NTILE(), Window Functions, CASE Expressions
-- ============================================================================

SET search_path TO retail_analytics;

-- ============================================================================
-- 3.1 RFM (Recency, Frequency, Monetary) Customer Segmentation
-- Uses nested CTEs and NTILE window function for scoring
-- ============================================================================
WITH customer_base AS (
    -- Step 1: Calculate raw RFM metrics per customer
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name              AS full_name,
        c.email,
        c.city,
        c.state,
        c.loyalty_tier,
        c.join_date,
        COUNT(DISTINCT t.transaction_id)                 AS total_orders,
        SUM(t.total_amount)                              AS total_spent,
        ROUND(AVG(t.total_amount), 2)                    AS avg_order_value,
        MAX(t.transaction_date)                          AS last_purchase_date,
        EXTRACT(DAY FROM NOW() - MAX(t.transaction_date))::INTEGER AS recency_days
    FROM customers c
    INNER JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.order_status = 'Completed'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email,
             c.city, c.state, c.loyalty_tier, c.join_date
    HAVING COUNT(DISTINCT t.transaction_id) >= 1
),
rfm_scored AS (
    -- Step 2: Assign RFM scores using NTILE (quintiles)
    SELECT
        cb.*,
        NTILE(5) OVER (ORDER BY recency_days DESC)      AS r_score, -- Lower recency = better = higher score
        NTILE(5) OVER (ORDER BY total_orders ASC)        AS f_score, -- Higher frequency = higher score
        NTILE(5) OVER (ORDER BY total_spent ASC)         AS m_score  -- Higher monetary = higher score
    FROM customer_base cb
),
rfm_segmented AS (
    -- Step 3: Map RFM scores to business segments
    SELECT
        rs.*,
        r_score + f_score + m_score                      AS rfm_total,
        r_score || '-' || f_score || '-' || m_score      AS rfm_cell,
        CASE
            -- High-value segments
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
                THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 4
                THEN 'Loyal High-Spenders'
            WHEN r_score >= 4 AND f_score >= 3 AND m_score >= 3
                THEN 'Loyal Customers'

            -- Growth potential segments
            WHEN r_score >= 4 AND f_score <= 2
                THEN 'Recent New Customers'
            WHEN r_score >= 3 AND f_score >= 2 AND m_score >= 2
                THEN 'Potential Loyalists'
            WHEN r_score >= 3 AND f_score >= 1 AND m_score >= 3
                THEN 'Big Spender Prospects'

            -- At-risk segments
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3
                THEN 'At Risk — High Value'
            WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4
                THEN 'Cannot Lose Them'
            WHEN r_score <= 2 AND f_score >= 2 AND m_score >= 2
                THEN 'About to Sleep'

            -- Low-engagement segments
            WHEN r_score <= 2 AND f_score <= 2
                THEN 'Hibernating'
            WHEN r_score <= 3 AND f_score <= 2 AND m_score <= 2
                THEN 'Lost Bargain Hunters'

            ELSE 'Need Attention'
        END                                               AS customer_segment
    FROM rfm_scored rs
)
SELECT
    customer_segment,
    COUNT(*)                                              AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS pct_of_customers,
    ROUND(AVG(total_orders), 1)                           AS avg_orders,
    ROUND(AVG(total_spent), 2)                            AS avg_lifetime_value,
    ROUND(AVG(avg_order_value), 2)                        AS avg_order_value,
    ROUND(AVG(recency_days), 0)                           AS avg_recency_days,
    SUM(total_spent)                                      AS segment_total_revenue,
    ROUND(SUM(total_spent) * 100.0 / SUM(SUM(total_spent)) OVER (), 2)
                                                           AS pct_of_revenue
FROM rfm_segmented
GROUP BY customer_segment
ORDER BY avg_lifetime_value DESC;

-- ============================================================================
-- 3.2 Customer Lifetime Value (CLV) Distribution
-- ============================================================================
WITH clv_metrics AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name              AS full_name,
        c.loyalty_tier,
        c.join_date,
        EXTRACT(MONTH FROM AGE(NOW(), c.join_date))      AS tenure_months,
        COUNT(DISTINCT t.transaction_id)                 AS total_orders,
        SUM(t.total_amount)                              AS lifetime_value,
        ROUND(AVG(t.total_amount), 2)                    AS avg_order_value,
        -- Average monthly spend
        ROUND(SUM(t.total_amount) / GREATEST(EXTRACT(MONTH FROM AGE(NOW(), c.join_date)), 1), 2)
                                                          AS avg_monthly_spend,
        -- Purchase frequency (orders per month)
        ROUND(COUNT(DISTINCT t.transaction_id)::NUMERIC /
              GREATEST(EXTRACT(MONTH FROM AGE(NOW(), c.join_date)), 1), 2)
                                                          AS purchase_frequency
    FROM customers c
    INNER JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.order_status = 'Completed'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.loyalty_tier, c.join_date
)
SELECT
    CASE
        WHEN lifetime_value < 100 THEN 'Micro ($0-$99)'
        WHEN lifetime_value < 500 THEN 'Low ($100-$499)'
        WHEN lifetime_value < 1000 THEN 'Medium ($500-$999)'
        WHEN lifetime_value < 2500 THEN 'High ($1K-$2.5K)'
        WHEN lifetime_value < 5000 THEN 'Very High ($2.5K-$5K)'
        ELSE 'Premium ($5K+)'
    END                                                   AS clv_tier,
    COUNT(*)                                              AS customer_count,
    ROUND(AVG(lifetime_value), 2)                         AS avg_clv,
    ROUND(AVG(total_orders), 1)                           AS avg_orders,
    ROUND(AVG(purchase_frequency), 2)                     AS avg_purchase_freq,
    ROUND(AVG(tenure_months), 0)                          AS avg_tenure_months,
    SUM(lifetime_value)                                   AS tier_total_revenue
FROM clv_metrics
GROUP BY
    CASE
        WHEN lifetime_value < 100 THEN 'Micro ($0-$99)'
        WHEN lifetime_value < 500 THEN 'Low ($100-$499)'
        WHEN lifetime_value < 1000 THEN 'Medium ($500-$999)'
        WHEN lifetime_value < 2500 THEN 'High ($1K-$2.5K)'
        WHEN lifetime_value < 5000 THEN 'Very High ($2.5K-$5K)'
        ELSE 'Premium ($5K+)'
    END
ORDER BY avg_clv DESC;

-- ============================================================================
-- 3.3 Customer Purchase Patterns — Repeat vs One-Time Buyers
-- ============================================================================
WITH purchase_counts AS (
    SELECT
        c.customer_id,
        c.loyalty_tier,
        c.city,
        c.state,
        COUNT(DISTINCT t.transaction_id) AS order_count,
        SUM(t.total_amount) AS total_spent,
        MIN(t.transaction_date) AS first_purchase,
        MAX(t.transaction_date) AS last_purchase,
        CASE
            WHEN COUNT(DISTINCT t.transaction_id) = 1 THEN 'One-Time'
            WHEN COUNT(DISTINCT t.transaction_id) BETWEEN 2 AND 3 THEN 'Occasional'
            WHEN COUNT(DISTINCT t.transaction_id) BETWEEN 4 AND 8 THEN 'Regular'
            ELSE 'Frequent'
        END AS buyer_type
    FROM customers c
    INNER JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.order_status = 'Completed'
    GROUP BY c.customer_id, c.loyalty_tier, c.city, c.state
)
SELECT
    buyer_type,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_customers,
    ROUND(AVG(order_count), 1) AS avg_orders,
    ROUND(AVG(total_spent), 2) AS avg_total_spent,
    SUM(total_spent) AS total_revenue,
    ROUND(SUM(total_spent) * 100.0 / SUM(SUM(total_spent)) OVER (), 2) AS pct_revenue
FROM purchase_counts
GROUP BY buyer_type
ORDER BY avg_orders;

-- ============================================================================
-- 3.4 Loyalty Tier Analysis — Value by Tier
-- ============================================================================
SELECT
    c.loyalty_tier,
    COUNT(DISTINCT c.customer_id)                        AS customer_count,
    COUNT(DISTINCT t.transaction_id)                     AS total_orders,
    SUM(t.total_amount)                                  AS total_revenue,
    ROUND(AVG(t.total_amount), 2)                        AS avg_order_value,
    ROUND(SUM(t.total_amount) / COUNT(DISTINCT c.customer_id), 2)
                                                          AS avg_revenue_per_customer,
    ROUND(COUNT(DISTINCT t.transaction_id)::NUMERIC / COUNT(DISTINCT c.customer_id), 1)
                                                          AS avg_orders_per_customer,
    ROUND(SUM(t.total_amount) * 100.0 / SUM(SUM(t.total_amount)) OVER (), 2)
                                                          AS revenue_contribution_pct,
    -- Tier efficiency: revenue per customer relative to average
    ROUND(
        (SUM(t.total_amount) / COUNT(DISTINCT c.customer_id)) /
        NULLIF((SUM(SUM(t.total_amount)) OVER () / SUM(COUNT(DISTINCT c.customer_id)) OVER ()), 0)
    , 2)                                                   AS tier_index
FROM customers c
INNER JOIN transactions t ON c.customer_id = t.customer_id
WHERE t.order_status = 'Completed'
GROUP BY c.loyalty_tier
ORDER BY
    CASE c.loyalty_tier
        WHEN 'Platinum' THEN 1
        WHEN 'Gold' THEN 2
        WHEN 'Silver' THEN 3
        WHEN 'Bronze' THEN 4
    END;

-- ============================================================================
-- 3.5 Geographic Customer Distribution
-- ============================================================================
WITH geo_metrics AS (
    SELECT
        c.state,
        c.city,
        COUNT(DISTINCT c.customer_id)                    AS customer_count,
        COUNT(DISTINCT t.transaction_id)                 AS total_orders,
        SUM(t.total_amount)                              AS total_revenue,
        ROUND(AVG(t.total_amount), 2)                    AS avg_order_value,
        ROUND(SUM(t.total_amount) / COUNT(DISTINCT c.customer_id), 2)
                                                          AS avg_revenue_per_customer
    FROM customers c
    INNER JOIN transactions t ON c.customer_id = t.customer_id
    WHERE t.order_status = 'Completed'
    GROUP BY c.state, c.city
)
SELECT
    state,
    city,
    customer_count,
    total_orders,
    total_revenue,
    avg_order_value,
    avg_revenue_per_customer,
    RANK() OVER (ORDER BY total_revenue DESC)            AS revenue_rank,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2)
                                                          AS revenue_share_pct
FROM geo_metrics
ORDER BY total_revenue DESC;
