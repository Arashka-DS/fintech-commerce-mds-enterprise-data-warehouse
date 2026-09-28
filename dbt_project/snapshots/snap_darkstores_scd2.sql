{% snapshot snap_darkstores_scd2 %}

{{
    config(
      target_schema='snapshots',
      unique_key='store_id',
      strategy='check',
      check_cols=['active_pickers', 'active_riders', 'is_active'],
      invalidate_hard_deletes=True
    )
}}

SELECT
    store_id,
    store_name,
    district_tehran,
    active_pickers,
    active_riders,
    is_active,
    opened_date
FROM {{ source('raw_qcommerce', 'darkstores') }}

{% endsnapshot %}
