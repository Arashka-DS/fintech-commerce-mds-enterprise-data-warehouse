{{ config(
    materialized='table',
    schema='staging' 
) }}

WITH source_data AS (
    SELECT * FROM {{ source('raw_fintech', 'transactions') }}
)

SELECT
    transaction_id,
    sender_id,
    receiver_id,
    amount_irr,
    transaction_type,
    status,
    initiated_at,
    settled_at,
    CURRENT_TIMESTAMP AS quarantined_at,
    ARRAY_TO_STRING(ARRAY[
        CASE WHEN amount_irr <= 0 THEN 'NEGATIVE_OR_ZERO_AMOUNT' END,
        CASE WHEN settled_at < initiated_at THEN 'INVALID_TEMPORAL_SEQUENCE' END,
        CASE WHEN status NOT IN ('SETTLED', 'PENDING', 'FAILED') THEN 'UNKNOWN_SETTLEMENT_STATUS' END,
        CASE WHEN sender_id IS NULL THEN 'ORPHAN_TRANSACTION_MISSING_SENDER' END
    ], ', ') AS failure_reasons
FROM source_data
WHERE amount_irr <= 0
   OR settled_at < initiated_at
   OR status NOT IN ('SETTLED', 'PENDING', 'FAILED')
   OR sender_id IS NULL
