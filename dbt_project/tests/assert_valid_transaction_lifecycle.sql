-- Singular Test: Completion timestamp must be chronologically equal to or after creation timestamp
SELECT 
    transaction_id,
    transaction_created_at,
    settled_at
FROM {{ ref('fct_transactions') }}
WHERE settled_at < transaction_created_at
