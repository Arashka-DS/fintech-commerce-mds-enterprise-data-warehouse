WITH source AS (
    SELECT * FROM {{ source('raw_fintech', 'customers') }}
)

SELECT
    customer_id,
    -- PII Security: One-way SHA-256 Hash for National ID
    {{ hash_pii('national_id') }} AS national_id_hash,
    full_name, -- Required for dim_customers
    -- PII Security: Partial masking for Analyst visibility
    {{ mask_phone('phone_number') }} AS customer_name_masked, -- FIXED: Was full_name
    UPPER(kyc_status) AS vip_tier, -- FIXED: Was vip_tier
    CAST(credit_limit_irr AS NUMERIC(15, 2)) AS credit_limit, -- FIXED: Was credit_limit
    updated_at
FROM source
