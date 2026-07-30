-- Business question: "do promotions actually move volume, and do they come with a higher cancellation rate?" 
-- Grain: one row per category + has_promotion flag.
-- ASSUMPTION: has_promotion is derived as "promotion_ids is populated", treating any non-blank value as "a promotion was applied" .Flagging this as a scope choice.

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
        case
            when fct.promotion_ids is not null and fct.promotion_ids != ''
            then true
            else false
        end as has_promotion,
        fct.is_cancelled,
        fct.quantity,
        fct.amount

    from fct
    left join product on fct.product_sk = product.product_sk

),

final as (

    select
        category,
        has_promotion,
        count(*)                                              as order_line_count,
        sum(case when not is_cancelled then quantity end)     as units_sold,
        sum(case when not is_cancelled then amount end)       as gross_revenue,
        {{ safe_divide(
            "sum(case when not is_cancelled then amount end)",
            "sum(case when not is_cancelled then quantity end)"
        ) }} as avg_price_per_unit,
        {{ safe_divide('sum(case when is_cancelled then 1 else 0 end)', 'count(*)') }} as cancellation_rate

    from joined
    group by category, has_promotion

)

select * from final