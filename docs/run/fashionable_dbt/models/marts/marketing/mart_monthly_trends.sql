
  
    
    

    create  table
      "fashionable"."main_marketing"."mart_monthly_trends__dbt_tmp"
  
    as (
      -- Business question: "what's the month-by-month trajectory?"  existing seasonal mart groups whole months into 4 buckets a year,
-- which hides month-to-month movement within a season. This mart adds finer granularity plus an explicit month-over-month growth figure.
-- Grain: one row per order_year + order_month + category.

with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

product as (

    select * from "fashionable"."main_core"."dim_product"
    where is_current

),

joined as (

    select
        extract(year from fct.order_date)  as order_year,
        extract(month from fct.order_date) as order_month,
        product.category,
        fct.is_cancelled,
        fct.quantity,
        fct.amount

    from fct
    left join product on fct.product_sk = product.product_sk

),

aggregated as (

    select
        order_year,
        order_month,
        category,
        count(*)                                              as order_line_count,
        sum(case when not is_cancelled then quantity end)     as units_sold,
        sum(case when not is_cancelled then amount end)       as gross_revenue

    from joined
    group by order_year, order_month, category

),

final as (

    select
        order_year,
        order_month,
        category,
        order_line_count,
        units_sold,
        gross_revenue,
        lag(gross_revenue) over (
            partition by category order by order_year, order_month
        ) as prior_month_revenue,
        
    -- Guards mart-level ratio calculations (e.g. avg order value,
    -- cancellation rate) against divide-by-zero when a group has no
    -- qualifying rows.
    case
        when lag(gross_revenue) over (partition by category order by order_year, order_month) = 0 or lag(gross_revenue) over (partition by category order by order_year, order_month) is null then null
        else (gross_revenue - lag(gross_revenue) over (partition by category order by order_year, order_month) * 1.0) / (lag(gross_revenue) over (partition by category order by order_year, order_month))
    end
 as revenue_mom_growth_rate

    from aggregated

)

select * from final
    );
  
  