-- Singular Test: Order's Cost must never be zero or negative
-- Returns failing rows (if query returns > 0 rows, dbt test fails)
SELECT 
    order_id,
    total_amount_irr
FROM {{ ref('fct_fulfillment_latency') }}
WHERE total_amount_irr <= 0.00
