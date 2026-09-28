-- Card 1: 24-Hour Settlement Throughput & Gateway Success Rate (Combo Chart)

SELECT 
    date_trunc('hour', t.transaction_created_at) AS time_window,
    t.gateway_type,
    COUNT(t.transaction_id) AS total_attempts,
    COUNT(CASE WHEN t.settlement_status = 'SETTLED' THEN 1 END) AS successful_settlements,
    ROUND(
        COUNT(CASE WHEN t.settlement_status = 'SETTLED' THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(t.transaction_id), 0) * 100, 
        2
    ) AS success_rate_pct
FROM analytics.fct_transactions t
WHERE t.transaction_created_at >= NOW() - INTERVAL '24 hours'
GROUP BY 1, 2
ORDER BY 1 DESC, 2;

-- Card 2: Top VIP Customers by Historical Settled Volume (Table View)

SELECT 
    c.customer_id,
    c.full_name,
    c.vip_tier,
    COUNT(t.transaction_id) AS lifetime_transactions,
    SUM(t.amount_irr) AS total_settled_amount_irr,
    ROUND(AVG(t.settlement_latency_seconds), 2) AS avg_latency_sec
FROM analytics.fct_transactions t
JOIN analytics.dim_customers c
    ON t.customer_dim_key = c.customer_dim_key
WHERE t.settlement_status = 'SETTLED'
  AND c.is_current_record = TRUE
GROUP BY 1, 2, 3
ORDER BY total_settled_amount_irr DESC
LIMIT 25;

-- Card 3: SCD Type 2 Audit: Historical VIP Tier Transitions (Sankey / Bar Chart)

SELECT 
    vip_tier,
    COUNT(customer_dim_key) AS historical_versions_count,
    COUNT(CASE WHEN is_current_record = TRUE THEN 1 END) AS active_tier_members,
    ROUND(AVG(credit_limit), 0) AS avg_tier_credit_limit
FROM analytics.dim_customers
GROUP BY 1
ORDER BY avg_tier_credit_limit DESC;
