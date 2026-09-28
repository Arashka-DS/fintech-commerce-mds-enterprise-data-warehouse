WITH transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

customers_scd AS (
    SELECT * FROM {{ ref('dim_customers') }}
)

SELECT
    t.transaction_id,
    -- Join to historical dimension record active AT THE EXACT MOMENT transaction occurred
    c.customer_dim_key,
    t.customer_id,
    t.amount_irr,
    t.currency,
    t.gateway_type,
    t.settlement_status,
    t.transaction_created_at,
    t.transaction_completed_at,
    ROUND(EXTRACT(EPOCH FROM (t.transaction_completed_at - t.transaction_created_at))::NUMERIC, 2) AS settlement_latency_seconds
FROM transactions t
LEFT JOIN customers_scd c
    ON t.customer_id = c.customer_id
    AND t.transaction_created_at >= c.valid_from
    AND (t.transaction_created_at < c.valid_to OR c.valid_to IS NULL)
