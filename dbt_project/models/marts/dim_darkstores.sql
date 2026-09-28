{{ config(
    materialized='table',
    schema='analytics'
) }}

WITH raw_stores AS (
    SELECT * FROM {{ source('raw_qcommerce', 'darkstores') }}
)

SELECT
    store_id,
    store_name,
    district_tehran,
    active_pickers,
    active_riders,
    is_active,
    opened_date,
    CASE 
        WHEN active_pickers >= 8 THEN 'HIGH_THROUGHPUT_TIER_1'
        ELSE 'STANDARD_TIER_2'
    END AS store_capacity_profile
FROM raw_stores
