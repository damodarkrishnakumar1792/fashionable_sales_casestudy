-- Business question from the brief: "which product styles/categories are
-- most popular in [city]?" Grain: one row per ship_state + ship_city +
-- category. Excludes cancelled lines from revenue, includes them in the
-- separate order/cancellation counts for visibility.

with fct as (

    select * from {{ ref('fct_order_lines') }}

),

loc as (

    select * from {{ ref('dim_ship_location') }}
    where is_current

),

product as (

    select * from {{ ref('dim_product') }}
    where is_current

),

joined as (

    select
        loc.ship_state,
        loc.ship_city,
        product.category,
        fct.is_cancelled,
        fct.quantity,
        fct.amount

    from fct
    left join loc on fct.ship_location_sk = loc.ship_location_sk
    left join product on fct.product_sk = product.product_sk

),

final as (

    select
        ship_state,
        ship_city,
        category,
        count(*)                                              as order_line_count,
        sum(case when not is_cancelled then quantity end)     as units_sold,
        sum(case when not is_cancelled then amount end)       as gross_revenue,
        sum(case when is_cancelled then 1 else 0 end)         as cancelled_line_count,
        {{ safe_divide('sum(case when is_cancelled then 1 else 0 end)', 'count(*)') }} as cancellation_rate

    from joined
    group by 1, 2, 3

)

select * from final
