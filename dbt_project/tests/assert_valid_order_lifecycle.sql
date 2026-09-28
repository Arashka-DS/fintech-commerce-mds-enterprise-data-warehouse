-- Singular test: Returns records that breach the natural chronological progression
SELECT
    order_id,
    order_received_at,
    picker_assigned_at,
    picking_completed_at,
    rider_dispatched_at,
    delivered_to_customer_at
FROM {{ ref('stg_darkstore_orders') }}
WHERE order_received_at > picker_assigned_at
   OR picker_assigned_at > picking_completed_at
   OR picking_completed_at > rider_dispatched_at
   OR rider_dispatched_at > delivered_to_customer_at
