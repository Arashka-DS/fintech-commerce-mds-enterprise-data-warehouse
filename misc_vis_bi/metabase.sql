-- ============================================================================
-- FINTECH EXECUTIVE METRICS
-- ============================================================================

-- CARD 1: Paya & Satna Settlement Velocity
SELECT 
    DATE_TRUNC('hour', initiated_at) AS settlement_hour,
    transaction_type,
    COUNT(transaction_id) AS total_transactions,
    ROUND(SUM(amount_irr) / 1000000000.0, 2) AS volume_in_billion_irr
FROM analytics.fct_transactions
GROUP BY 1, 2
ORDER BY 1 DESC;

-- CARD 2: SCD Type 2 Credit Limit Exposure Tracker
SELECT 
    customer_id,
    masked_name,
    credit_limit_irr,
    dbt_valid_from,
    dbt_valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN 'CURRENT' ELSE 'HISTORICAL' END AS record_status
FROM analytics.dim_customers
ORDER BY customer_id, dbt_valid_from DESC;

-- ============================================================================
-- Q-COMMERCE DARKSTORE OPERATIONS METRICS
-- ============================================================================

-- CARD 3: 30-Minute SLA Breach Rate by Tehran Darkstore Hub
SELECT 
    store_name,
    district_tehran,
    COUNT(order_id) AS total_orders,
    SUM(CASE WHEN is_sla_breached THEN 1 ELSE 0 END) AS breached_orders,
    ROUND((SUM(CASE WHEN is_sla_breached THEN 1 ELSE 0 END)::NUMERIC / COUNT(order_id)::NUMERIC) * 100.0, 2) AS sla_breach_rate_pct
FROM analytics.fct_fulfillment_latency
GROUP BY store_name, district_tehran
ORDER BY sla_breach_rate_pct DESC;

-- CARD 4: Darkstore Bottleneck Root-Cause Breakdown
SELECT 
    sla_breach_primary_cause,
    COUNT(order_id) AS incident_count,
    ROUND(AVG(total_fulfillment_minutes), 2) AS avg_duration_minutes
FROM analytics.fct_fulfillment_latency
WHERE is_sla_breached = TRUE
GROUP BY sla_breach_primary_cause
ORDER BY incident_count DESC;

-- CARD 5: Dead-Letter Data Quarantine Audit (Data Quality Dashboard)
SELECT 
    quarantine_reason,
    COUNT(order_id) AS total_corrupt_records,
    MAX(quarantined_at) AS last_detected_at
FROM staging.quarantine_invalid_orders
GROUP BY quarantine_reason;
