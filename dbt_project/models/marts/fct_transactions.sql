{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    schema='analytics'
) }}

WITH stg_transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
    {% if is_incremental() %}
        -- 3-day dynamic lookback window for late-arriving clearinghouse settlements
        WHERE initiated_at >= (SELECT COALESCE(MAX(initiated_at), '1970-01-01') - INTERVAL '3 days' FROM {{ this }})
    {% endif %}
),
dim_customers AS (
    SELECT * FROM {{ ref('dim_customers') }}
    WHERE is_current_record = TRUE
)

SELECT
    t.transaction_id,
    t.sender_id,
    t.receiver_id,
    t.amount_irr,
    t.transaction_type,
    t.initiated_at,
    t.settled_at,
    t.status,
    c.masked_name AS sender_masked_name,
    ROUND(EXTRACT(EPOCH FROM (t.settled_at - t.initiated_at)) / 60.0, 2) AS settlement_latency_minutes
FROM stg_transactions t
LEFT JOIN dim_customers c ON t.sender_id = c.customer_id
