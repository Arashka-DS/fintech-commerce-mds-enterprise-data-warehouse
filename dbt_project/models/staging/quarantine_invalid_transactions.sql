{{ config(
    materialized='table',
    schema='staging'
) }}

WITH raw_orders AS (
    SELECT * FROM {{ source('raw_qcommerce', 'orders') }}
)

SELECT
    order_id,
    store_id,
    customer_id,
    total_amount_irr,
    order_received_at,
    picker_assigned_at,
    picking_completed_at,
    rider_dispatched_at,
    delivered_to_customer_at,
    status,
    CASE
        WHEN total_amount_irr <= 0 THEN 'NEGATIVE_OR_ZERO_TOTAL'
        WHEN picking_completed_at < picker_assigned_at THEN 'INVALID_PICKING_TIMESTAMPS'
        WHEN delivered_to_customer_at < rider_dispatched_at THEN 'INVALID_TRANSIT_TIMESTAMPS'
        WHEN delivered_to_customer_at < order_received_at THEN 'DELIVERY_PRECEDES_ORDER'
        ELSE 'OTHER_CORRUPTION'
    END AS quarantine_reason,
    CURRENT_TIMESTAMP AS quarantined_at
FROM raw_orders
WHERE total_amount_irr <= 0
   OR picking_completed_at < picker_assigned_at
   OR delivered_to_customer_at < rider_dispatched_at
   OR delivered_to_customer_at < order_received_at
