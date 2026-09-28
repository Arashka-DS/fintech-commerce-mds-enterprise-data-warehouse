WITH source AS (
    SELECT * FROM {{ source('raw_fintech', 'customers') }}
)

SELECT
    customer_id,
    -- PII Security: One-way SHA-256 Hash for National ID
    {{ hash_pii_sha256('national_id') }} AS national_id_hash,
    -- PII Security: Partial masking for Analyst visibility without compliance breach
    {{ mask_string_partial('full_name') }} AS customer_name_masked,
    UPPER(vip_tier) AS vip_tier,
    CAST(credit_limit AS NUMERIC(15, 2)) AS credit_limit,
    updated_at
FROM source
