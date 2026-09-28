{{ config(
    materialized='incremental',
    unique_key='order_id',
    schema='analytics'
) }}

WITH stg_orders AS (
    SELECT * FROM {{ ref('stg_darkstore_orders') }}
    {% if is_incremental() %}
        WHERE order_received_at >= (SELECT COALESCE(MAX(order_received_at), '1970-01-01') - INTERVAL '3 days' FROM {{ this }})
    {% endif %}
)

SELECT
    order_id,
    store_id,
    customer_id,
    total_amount,
    
    -- Phase 1: Picking Efficiency (Store Floor)
    ROUND(EXTRACT(EPOCH FROM (picking_completed_at - picker_assigned_at))::NUMERIC, 2) AS pick_latency_seconds,
    
    -- Phase 2: Rider Orchestration (Waiting for Courier)
    ROUND(EXTRACT(EPOCH FROM (rider_dispatched_at - picking_completed_at))::NUMERIC, 2) AS rider_wait_seconds,
    
    -- Phase 3: Last-Mile Delivery
    ROUND(EXTRACT(EPOCH FROM (delivered_to_customer_at - rider_dispatched_at))::NUMERIC, 2) AS last_mile_transit_seconds,
    
    -- Total Customer Promise Latency
    ROUND(EXTRACT(EPOCH FROM (delivered_to_customer_at - order_received_at))::NUMERIC / 60.0, 2) AS total_fulfillment_minutes,
    
    -- SLA Breach Flag (The 30-Minute Promise)
    CASE 
        WHEN EXTRACT(EPOCH FROM (delivered_to_customer_at - order_received_at)) / 60.0 > 30.0 THEN TRUE 
        ELSE FALSE 
    END AS is_sla_breached

FROM stg_orders
