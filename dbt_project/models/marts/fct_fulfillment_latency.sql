{{ config(
    materialized='incremental',
    unique_key='order_id',
    schema='analytics'
) }}

WITH orders AS (
    SELECT * FROM {{ ref('stg_darkstore_orders') }}
    {% if is_incremental() %}
        WHERE order_received_at >= (SELECT COALESCE(MAX(order_received_at), '1970-01-01') - INTERVAL '3 days' FROM {{ this }})
    {% endif %}
),

stores AS (
    SELECT * FROM {{ ref('dim_darkstores') }}
)

SELECT
    o.order_id,
    o.store_id,
    s.store_name,
    s.district_tehran,
    o.customer_id,
    o.total_amount_irr,
    o.order_received_at,
    
    -- Phase 1: Picking Duration (Floor operations)
    ROUND(EXTRACT(EPOCH FROM (o.picking_completed_at - o.picker_assigned_at))::NUMERIC, 2) AS pick_latency_seconds,
    
    -- Phase 2: Rider Wait Duration (Dispatch queue)
    ROUND(EXTRACT(EPOCH FROM (o.rider_dispatched_at - o.picking_completed_at))::NUMERIC, 2) AS rider_wait_seconds,
    
    -- Phase 3: Transit Duration (Last mile couriers)
    ROUND(EXTRACT(EPOCH FROM (o.delivered_to_customer_at - o.rider_dispatched_at))::NUMERIC, 2) AS last_mile_transit_seconds,
    
    -- Total Fulfillment Time
    ROUND(EXTRACT(EPOCH FROM (o.delivered_to_customer_at - o.order_received_at))::NUMERIC / 60.0, 2) AS total_fulfillment_minutes,
    
    -- SLA Breach Evaluation (> 30.0 minutes)
    CASE 
        WHEN EXTRACT(EPOCH FROM (o.delivered_to_customer_at - o.order_received_at)) / 60.0 > 30.0 THEN TRUE 
        ELSE FALSE 
    END AS is_sla_breached,

    -- Operational Root Cause Analysis
    CASE 
        WHEN EXTRACT(EPOCH FROM (o.delivered_to_customer_at - o.order_received_at)) / 60.0 <= 30.0 THEN 'SLA_MET'
        WHEN EXTRACT(EPOCH FROM (o.picking_completed_at - o.picker_assigned_at)) > 600 THEN 'PICKING_BOTTLENECK'
        WHEN EXTRACT(EPOCH FROM (o.rider_dispatched_at - o.picking_completed_at)) > 480 THEN 'RIDER_DISPATCH_DELAY'
        ELSE 'LAST_MILE_TRAFFIC'
    END AS sla_breach_primary_cause

FROM orders o
LEFT JOIN stores s ON o.store_id = s.store_id
