
  
    
    

    create  table
      "fashionable"."main_marketing"."mart_location_repeat_activity__dbt_tmp"
  
    as (
      -- Business question: "which ship-to locations order more than once?" — Postal code is the closest usable proxy for "the same real-world buyer" - imperfect (a postal code can cover many
-- households), but a real, non-fabricated signal based on the dataset.

-- Grain: one row per ship_postal_code.

-- Joined against the FULL dim_ship_location snapshot (not filtered to is_current), and grouped by the natural key ship_postal_code ratherthan the surrogate ship_location_sk — a Type-2 dimension can have
-- multiple sk versions for the same real postal code over time, and grouping by sk would undercount repeat activity for a location whose city/state got corrected mid-history.

with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

loc as (

    select * from "fashionable"."main_core"."dim_ship_location"

),

joined as (

    select
        loc.ship_postal_code,
        loc.ship_city,
        loc.ship_state,
        fct.order_id,
        fct.order_date,
        fct.is_cancelled,
        fct.amount

    from fct
    left join loc on fct.ship_location_sk = loc.ship_location_sk

),

aggregated as (

    select
        ship_postal_code,
        -- city/state should be consistent per postal code in practice;
        -- max() here is a tie-breaker if a Type-2 correction mid-history
        max(ship_city)                                          as ship_city,
        max(ship_state)                                          as ship_state,
        count(distinct order_id)                                 as distinct_order_count,
        count(distinct order_date)                                as distinct_order_dates,
        min(order_date)                                            as first_order_date,
        max(order_date)                                            as last_order_date,
        sum(case when not is_cancelled then amount end)            as total_revenue

    from joined
    group by ship_postal_code

),

final as (

    select
        *,
        distinct_order_count > 1                                as is_repeat_location,
        date_diff('day', first_order_date, last_order_date)       as active_span_days

    from aggregated

)

select * from final
    );
  
  