-- Grain: one row per order line (order_id + sku + asin + courier_status) which is unchanged from staging.
-- Business logic here so staging stays a typed pass-through.

with stg_sales as (

    select * from {{ ref('stg_fashionable_sales') }}

),

enriched as (

    select
        *,
        {{ get_season('order_date') }} as season,

        case
            when order_status = 'Cancelled' then true
            else false
        end as is_cancelled,

        {{ dbt_utils.generate_surrogate_key(['order_id', 'sku','asin','courier_status']) }} as order_line_key,

        -- 'sku' is treated as the durable natural key for the Type-2 SCD dim_product snapshot.
        sku as product_natural_key,

        -- Matches the unique_key used in dim_ship_location_snapshot so the fact table can join to it directly.
        ship_postal_code as ship_location_natural_key,
        {{ dbt_utils.generate_surrogate_key(['fulfilment', 'sales_channel', 'ship_service_level', 'courier_status', 'fulfilled_by', 'is_b2b']) }} as fulfilment_key

    from stg_sales

)

select * from enriched
