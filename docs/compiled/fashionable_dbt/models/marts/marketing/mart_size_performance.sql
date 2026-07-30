-- Business question: "which sizes sell well vs. get cancelled most, within each category?" : relevant to inventory/sizing decisions
-- Grain: one row per category + size.

with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

product as (

    select * from "fashionable"."main_core"."dim_product"
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
        
    -- Guards mart-level ratio calculations (e.g. avg order value,
    -- cancellation rate) against divide-by-zero when a group has no
    -- qualifying rows.
    case
        when count(*) = 0 or count(*) is null then null
        else (sum(case when is_cancelled then 1 else 0 end) * 1.0) / (count(*))
    end
 as cancellation_rate

    from joined
    group by category, size

)

select * from final