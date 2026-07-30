{% snapshot dim_product_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='sku',
      strategy='check',
      check_cols=['style', 'category', 'size', 'asin'],
    )
}}

-- NOTE: this assumes 'sku' is unique per distinct product-attribute
-- combination in the source. If a single sku appears with more than one combination of (style, category, size, asin) at the SAME point in time
-- (not over time), this snapshot's unique_key assumption breaks and dbt will error on the snapshot run which treat that as a real data-quality
-- finding, not a bug to silently work around.
select distinct
    sku,
    style,
    category,
    size,
    asin
from {{ ref('stg_fashionable_sales') }}

{% endsnapshot %}
