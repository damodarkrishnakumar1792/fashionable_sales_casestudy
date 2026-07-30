-- Business question: "where exactly are cancellations concentrated?" —
-- This mart crosses three dimensions at once (category x ship_state x fulfilment)
-- Grain: one row per category + ship_state + fulfilment.
-- NOTE: this is intentionally high-cardinality and will include many low-volume combinations. order_line_count is included specifically so
-- a downstream consumer can filter out statistically thin groups (e.g.order_line_count < 10) rather than this mart silently pre-filtering
-- and hiding which combinations were excluded.

with fct as (

    select * from {{ ref('fct_order_lines') }}

),

product as (

    select * from {{ ref('dim_product') }}
    where is_current

),

loc as (

    select * from {{ ref('dim_ship_location') }}
    where is_current

),

fulfilment as (

    select * from {{ ref('dim_fulfilment') }}

),

joined as (

    select
        product.category,
        loc.ship_state,
        fulfilment.fulfilment,
        fct.is_cancelled

    from fct
    left join product on fct.product_sk = product.product_sk
    left join loc on fct.ship_location_sk = loc.ship_location_sk
    left join fulfilment on fct.fulfilment_sk = fulfilment.fulfilment_sk

),

final as (

    select
        category,
        ship_state,
        fulfilment,
        count(*)                                                as order_line_count,
        sum(case when is_cancelled then 1 else 0 end)            as cancelled_line_count,
        {{ safe_divide('sum(case when is_cancelled then 1 else 0 end)', 'count(*)') }} as cancellation_rate

    from joined
    group by category, ship_state, fulfilment

)

select * from final