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
        product.style,
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
        style,
        size,
        count(*)                                            as order_line_count,
        sum(case when not is_cancelled then quantity end)   as units_sold,
        sum(case when not is_cancelled then amount end)     as gross_revenue,
        {{ safe_divide(
            "sum(case when not is_cancelled then amount end)",
            "sum(case when not is_cancelled then quantity end)"
        ) }} as avg_price_per_unit

    from joined
    group by 1, 2, 3

)

select * from final
