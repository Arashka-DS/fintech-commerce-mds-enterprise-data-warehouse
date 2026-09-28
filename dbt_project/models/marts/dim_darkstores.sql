{{ config(
    materialized='table',
    schema='analytics'
) }}

WITH scd2_stores AS (
    SELECT * FROM {{ ref('snap_darkstores_scd2') }}
)

SELECT
    store_id,
    store_name,
    district_tehran,
    active_pickers,
    active_riders,
    is_active,
    opened_date,
    dbt_valid_from,
    dbt_valid_to,
    CASE WHEN dbt_valid_to IS NULL THEN TRUE ELSE FALSE END AS is_current_capacity,
    CASE 
        WHEN active_pickers >= 8 THEN 'TIER_1_HIGH_THROUGHPUT'
        ELSE 'TIER_2_STANDARD'
    END AS store_capacity_tier
FROM scd2_stores
