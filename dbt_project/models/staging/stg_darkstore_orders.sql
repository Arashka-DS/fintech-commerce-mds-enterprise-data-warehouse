{{ config(
    materialized='view',
    schema='staging'
) }}

WITH source AS (
    SELECT * FROM {{ source('raw_qcommerce', 'orders') }}
),

quarantined AS (
    SELECT order_id FROM {{ ref('quarantine_invalid_orders') }}
)

SELECT
    s.order_id,
    s.store_id,
    {{ hash_pii('s.customer_id') }} AS masked_customer_token,
    s.total_amount_irr,
    s.order_received_at,
    s.picker_assigned_at,
    s.picking_completed_at,
    s.rider_dispatched_at,
    s.delivered_to_customer_at,
    s.status
FROM source s
LEFT JOIN quarantined q ON s.order_id = q.order_id
WHERE q.order_id IS NULL
  AND s.status = 'DELIVERED'
