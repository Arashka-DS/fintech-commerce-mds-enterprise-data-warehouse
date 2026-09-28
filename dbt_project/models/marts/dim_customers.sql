WITH scd_data AS (
    SELECT * FROM {{ ref('snap_customers_scd2') }}
)

SELECT
    -- Deterministic Surrogate Key for SCD Type 2 dimension matching
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'dbt_valid_from']) }} AS customer_dim_key,
    customer_id,
    national_id,
    full_name,
    vip_tier,
    credit_limit,
    dbt_valid_from AS valid_from,
    dbt_valid_to AS valid_to,
    CASE 
        WHEN dbt_valid_to IS NULL THEN TRUE 
        ELSE FALSE 
    END AS is_current_record
FROM scd_data
