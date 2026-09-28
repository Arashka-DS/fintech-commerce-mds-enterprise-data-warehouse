WITH source AS (
    SELECT * FROM {{ source('raw_fintech', 'transactions') }}
)

SELECT
    transaction_id,
    customer_id,
    CAST(amount AS NUMERIC(15, 2)) AS amount_irr,
    UPPER(currency) AS currency,
    UPPER(gateway_type) AS gateway_type,
    UPPER(status) AS settlement_status,
    created_at AS transaction_created_at,
    completed_at AS transaction_completed_at
FROM source
