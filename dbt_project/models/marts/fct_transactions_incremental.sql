{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    schema='analytics',
    indexes=[
      {'columns': ['transaction_created_at']},
      {'columns': ['customer_dim_key']}
    ]
) }}

WITH valid_stg_transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
    -- Filter out records quarantined by our sanitization layer
    WHERE transaction_id NOT IN (
        SELECT transaction_id FROM {{ ref('quarantine_invalid_transactions') }}
    )
    {% if is_incremental() %}
        -- 3-day lookback window guarantees late-arriving batch POS records are captured
        AND transaction_created_at >= (
            SELECT COALESCE(MAX(transaction_created_at), '1970-01-01') - INTERVAL '3 days' 
            FROM {{ this }}
        )
    {% endif %}
),

customers_scd AS (
    SELECT * FROM {{ ref('dim_customers') }}
)

SELECT
    t.transaction_id,
    c.customer_dim_key,
    t.customer_id,
    t.amount_irr,
    t.currency,
    t.gateway_type,
    t.settlement_status,
    t.transaction_created_at,
    t.transaction_completed_at,
    ROUND(EXTRACT(EPOCH FROM (t.transaction_completed_at - t.transaction_created_at))::NUMERIC, 2) AS settlement_latency_seconds
FROM valid_stg_transactions t
LEFT JOIN customers_scd c
    ON t.customer_id = c.customer_id
    AND t.transaction_created_at >= c.valid_from
    AND (t.transaction_created_at < c.valid_to OR c.valid_to IS NULL)
