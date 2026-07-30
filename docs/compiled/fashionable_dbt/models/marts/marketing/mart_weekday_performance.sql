-- Business question: "which days of the week drive the most sales/cancellations?" — useful for promo timing and staffing decisions.
-- Grain: one row per day_of_week.
-- NOTE ON CONVENTION: DuckDB's extract(dow from date) is assumed here to return 0=Sunday..6=Saturday

with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

with_day as (

    select
        extract(dow from order_date)                            as day_of_week_num,
        is_cancelled,
        quantity,
        amount

    from fct

),

final as (

    select
        day_of_week_num,
        case day_of_week_num
            when 0 then 'Sunday'
            when 1 then 'Monday'
            when 2 then 'Tuesday'
            when 3 then 'Wednesday'
            when 4 then 'Thursday'
            when 5 then 'Friday'
            when 6 then 'Saturday'
        end                                                       as day_name,
        day_of_week_num in (0, 6)                                  as is_weekend,
        count(*)                                                   as order_line_count,
        sum(case when not is_cancelled then quantity end)          as units_sold,
        sum(case when not is_cancelled then amount end)            as gross_revenue,
        
    -- Guards mart-level ratio calculations (e.g. avg order value,
    -- cancellation rate) against divide-by-zero when a group has no
    -- qualifying rows.
    case
        when count(*) = 0 or count(*) is null then null
        else (sum(case when is_cancelled then 1 else 0 end) * 1.0) / (count(*))
    end
 as cancellation_rate

    from with_day
    group by day_of_week_num

)

select * from final