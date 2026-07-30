{% snapshot dim_ship_location_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='ship_postal_code',
      strategy='check',
      check_cols=['ship_city', 'ship_state', 'ship_country'],
    )
}}

-- unique_key is ship_postal_code (a more durable identifier than a composite of all four fields — if the key itself were derived from
-- the columns being change-tracked). 
-- ASSUMPTION: postal code is treated as 1:1 with a single city/state at any point in time but can be unknown or null as well
select distinct
    upper(trim(regexp_replace(ship_postal_code, '\.0$', ''))) as ship_postal_code,
    ship_city,
    ship_state,
    ship_country
from {{ ref('stg_fashionable_sales') }}
where ship_postal_code is not null

{% endsnapshot %}
