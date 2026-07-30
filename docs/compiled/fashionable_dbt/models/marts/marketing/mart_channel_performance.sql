with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

fulfilment as (

    select * from "fashionable"."main_core"."dim_fulfilment"

),

joined as (

    select
        fulfilment.fulfilment,
        fulfilment.sales_channel,
        fulfilment.ship_service_level,
        fulfilment.is_b2b,
        fct.is_cancelled,
        fct.quantity,
        fct.amount

    from fct
    left join fulfilment on fct.fulfilment_sk = fulfilment.fulfilment_sk

),

final as (

    select
        fulfilment,
        sales_channel,
        ship_service_level,
        is_b2b,
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
    group by 1, 2, 3, 4

)

select * from final