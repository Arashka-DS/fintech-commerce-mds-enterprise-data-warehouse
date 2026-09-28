{{ config(
    materialized='table',
    schema='quarantine'
) }}

WITH source_data AS (
    SELECT * FROM {{ source('raw_fintech', 'transactions') }}
)

SELECT
    transaction_id,
    customer_id,
    amount,
    currency,
    gateway_type,
    status,
    created_at,
    completed_at,
    CURRENT_TIMESTAMP AS quarantined_at,
    ARRAY_TO_STRING(ARRAY[
        CASE WHEN amount <= 0 THEN 'NEGATIVE_OR_ZERO_AMOUNT' END,
        CASE WHEN completed_at < created_at THEN 'INVALID_TEMPORAL_SEQUENCE' END,
        CASE WHEN status NOT IN ('SETTLED', 'PENDING', 'FAILED') THEN 'UNKNOWN_SETTLEMENT_STATUS' END,
        CASE WHEN customer_id IS NULL THEN 'ORPHAN_TRANSACTION_MISSING_CUSTOMER' END
    ], ', ') AS failure_reasons
FROM source_data
WHERE amount <= 0
   OR completed_at < created_at
   OR status NOT IN ('SETTLED', 'PENDING', 'FAILED')
   OR customer_id IS NULL
