-- Business question: "which sizes sell well vs. get cancelled most, within each category?" : relevant to inventory/sizing decisions
-- Grain: one row per category + size.

with fct as (

    select * from {{ ref('fct_order_lines') }}

),

product as (

    select * from {{ ref('dim_product') }}
    where is_current

),

joined as (

    select
        product.category,
        product.size,
        fct.is_cancelled,
        fct.quantity,
        fct.amount

    from fct
    left join product on fct.product_sk = product.product_sk

),

final as (

    select
        category,
        size,
        count(*)                                              as order_line_count,
        sum(case when not is_cancelled then quantity end)     as units_sold,
        sum(case when not is_cancelled then amount end)       as gross_revenue,
        {{ safe_divide('sum(case when is_cancelled then 1 else 0 end)', 'count(*)') }} as cancellation_rate

    from joined
    group by category, size

)

select * from final