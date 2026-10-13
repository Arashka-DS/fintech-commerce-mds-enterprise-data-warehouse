WITH source AS (
    SELECT * FROM {{ source('raw_fintech', 'transactions') }}
),
quarantined AS (
    SELECT transaction_id FROM {{ ref('quarantine_invalid_transactions') }}
)
SELECT
    s.transaction_id,
    s.customer_id AS sender_id,
    CAST(s.amount AS NUMERIC(15, 2)) AS amount_irr,
    UPPER(currency) AS currency,
    UPPER(gateway_type) AS transaction_type,
    UPPER(status) AS status,
    created_at AS initiated_at,
    completed_at AS settled_at
FROM source s
LEFT JOIN quarantined q ON s.transaction_id = q.transaction_id
WHERE q.transaction_id IS NULL
