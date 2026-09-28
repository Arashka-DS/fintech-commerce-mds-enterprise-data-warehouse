{% snapshot snap_customers_scd2 %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at',
        invalidate_hard_deletes=True
    )
}}

SELECT 
    customer_id,
    national_id,
    full_name,
    vip_tier,
    credit_limit,
    updated_at
FROM {{ source('raw_fintech', 'customers') }}

{% endsnapshot %}
