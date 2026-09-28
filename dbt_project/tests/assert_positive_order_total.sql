-- Singular Test: Transaction amounts must never be zero or negative
-- Returns failing rows (if query returns > 0 rows, dbt test fails)
SELECT 
    transaction_id,
    amount_irr
FROM {{ ref('fct_transactions') }}
WHERE amount_irr <= 0.00
