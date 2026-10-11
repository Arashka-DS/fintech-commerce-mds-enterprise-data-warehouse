WITH source AS (
    SELECT * FROM {{ source('raw_fintech', 'transactions') }}
)

SELECT
    transaction_id,
    customer_id AS sender_id, -- Mapped for fct_transactions
    CAST(amount AS NUMERIC(15, 2)) AS amount_irr,
    UPPER(currency) AS currency,
    UPPER(gateway_type) AS transaction_type, -- Mapped for fct_transactions
    UPPER(status) AS status, -- Mapped for fct_transactions
    created_at AS initiated_at, -- Mapped for fct_transactions
    completed_at AS settled_at -- Mapped for fct_transactions
FROM source
