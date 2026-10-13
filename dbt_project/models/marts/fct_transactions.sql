{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    schema='analytics'
) }}

WITH stg_transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
    {% if is_incremental() %}
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
    c_sender.customer_dim_key AS sender_dim_key,
    c_sender.masked_name AS sender_masked_name,
    t.receiver_id,
    c_receiver.customer_dim_key AS receiver_dim_key,
    c_receiver.masked_name AS receiver_masked_name,
    t.amount_irr,
    t.transaction_type,
    t.initiated_at AS transaction_created_at,
    t.settled_at,
    t.status AS settlement_status,
    ROUND(EXTRACT(EPOCH FROM (t.settled_at - t.initiated_at)) / 60.0, 2) AS settlement_latency_minutes
FROM stg_transactions t
LEFT JOIN dim_customers c_sender ON t.sender_id = c_sender.customer_id
LEFT JOIN dim_customers c_receiver ON t.receiver_id = c_receiver.customer_id
