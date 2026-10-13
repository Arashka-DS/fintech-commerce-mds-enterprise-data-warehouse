WITH source AS (
    SELECT * FROM {{ source('raw_fintech', 'transactions') }}
),
quarantined AS (
    SELECT transaction_id FROM {{ ref('quarantine_invalid_transactions') }}
)

SELECT
    s.transaction_id,
    s.sender_id,
    s.receiver_id,
    s.amount_irr,
    UPPER(s.transaction_type) AS transaction_type,
    UPPER(s.status) AS status,
    s.initiated_at,
    s.settled_at
FROM source s
LEFT JOIN quarantined q ON s.transaction_id = q.transaction_id
WHERE q.transaction_id IS NULL
