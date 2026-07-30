-- Grain: one row per order line (order_id, sku). Confirmed against the source via a uniqueness test in stg_fashionable_sales.yml.
-- Type-2 dims are joined point-in-time: order_date must fall within [dbt_valid_from, coalesce(dbt_valid_to, future date)) on the dim side.

-- INCREMENTAL: this is the one model in the project built incrementally,
-- since it's the largest and the one that would matter most at real data volume. Watermarked on order_date rather than a load timestamp,

-- ASSUMPTION: Assuming the raw source is append-only (new order lines only ever have order_date later than what's already loaded).
-- If historical corrections can land with an old order_date, watermark can be switched to a real load/ingestion timestamp once one exists upstream, or run periodic `--full-refresh` builds.
-- Incremental strategy chosen is 'merge' for broad adapter compatibility

{{
    config(
        materialized='incremental',
        unique_key='order_line_key',
        incremental_strategy='merge',
		on_schema_change='fail'
    )
}}

with sales as (

    select * from {{ ref('int_sales_enriched') }}

    {% if is_incremental() %}
    where order_date > (select coalesce(max(order_date), '1900-01-01'::date) from {{ this }})
    {% endif %}

),

product as (

    select * from {{ ref('dim_product') }}

),

ship_location as (

    select * from {{ ref('dim_ship_location') }}

),

fulfilment as (

    select * from {{ ref('dim_fulfilment') }}

),

date_dim as (

    select * from {{ ref('dim_date') }}

),

final as (

    select
        sales.order_line_key,

        -- degenerate dimension: no separate dim_order developed at this grain
        sales.order_id,

        product.product_sk,
        ship_location.ship_location_sk,
        fulfilment.fulfilment_sk,
        date_dim.date_key                              as order_date_key,

        sales.order_date,
        sales.order_status,
        sales.is_cancelled,
        sales.season,
        sales.quantity,
        sales.amount,
        sales.currency_code,
        sales.promotion_ids,

		cast(sales._loaded_at as timestamp) as _loaded_at,
        sales._dbt_run_date

    from sales

    left join product
        on sales.product_natural_key = product.sku
        --and sales.order_date >= cast(product.dbt_valid_from as date)
        --and sales.order_date <  coalesce(cast(product.dbt_valid_to as date), cast('9999-12-31' as date))


    left join ship_location
        on sales.ship_location_natural_key = ship_location.ship_postal_code
        --and sales.order_date >= cast(ship_location.dbt_valid_from as date)
        --and sales.order_date <  coalesce(cast(ship_location.dbt_valid_to as date), cast('9999-12-31' as date))

    left join fulfilment
        on sales.fulfilment_key = fulfilment.fulfilment_sk

    left join date_dim
        on sales.order_date = date_dim.date_day

)

select * from final
