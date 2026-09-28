-- Singular test: Returns financial transactions that have non-positive amounts
SELECT
    transaction_id,
    amount_irr
FROM {{ ref('stg_transactions') }}
WHERE amount_irr <= 0
