-- Singular Test: Completion timestamp must be chronologically equal to or after creation timestamp
SELECT 
    transaction_id,
    transaction_created_at,
    transaction_completed_at
FROM {{ ref('fct_transactions') }}
WHERE transaction_completed_at < transaction_created_at
