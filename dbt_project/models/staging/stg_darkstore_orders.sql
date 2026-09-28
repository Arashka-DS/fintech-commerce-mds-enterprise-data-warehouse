WITH source AS (
    SELECT * FROM {{ source('raw_qcommerce', 'orders') }}
)

SELECT
    order_id,
    store_id,
    customer_id,
    total_amount,
    order_received_at,
    picker_assigned_at,
    picking_completed_at,
    rider_dispatched_at,
    delivered_to_customer_at
FROM source
WHERE status != 'CANCELLED'
