WITH source AS (
    SELECT * FROM {{ source('raw_fintech', 'customers') }}
)

SELECT
    customer_id,
    national_id,
    TRIM(full_name) AS customer_name,
    UPPER(vip_tier) AS vip_tier,
    CAST(credit_limit AS NUMERIC(15, 2)) AS credit_limit,
    updated_at
FROM source
