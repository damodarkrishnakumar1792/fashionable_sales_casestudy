-- Business question: "what's our average order value / basket size?"
-- Grain: one row per order_id. (need "one row per order," not "one row per item in an order.")

with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

grouped as (

    select
        order_id,
        min(order_date)                                        as order_date,
        count(*)                                                as line_item_count,
        -- Distinct product_sk, not distinct sku
        count(distinct product_sk)                              as distinct_product_count,
        sum(case when not is_cancelled then quantity end)       as total_units,
        sum(case when not is_cancelled then amount end)         as order_total_amount,
        sum(case when is_cancelled then 1 else 0 end)           as cancelled_line_count

    from fct
    group by order_id

),

final as (

    select
        order_id,
        order_date,
        line_item_count,
        distinct_product_count,
        total_units,
        order_total_amount,
        cancelled_line_count,
        line_item_count > 1                                     as is_multi_item_order,
        case
            when cancelled_line_count = line_item_count then 'Fully Cancelled'
            when cancelled_line_count > 0 then 'Partially Cancelled'
            else 'Completed'
        end as order_fulfillment_status

    from grouped

)

select * from final