
  
    
    

    create  table
      "fashionable"."main_marketing"."mart_seasonal_trends__dbt_tmp"
  
    as (
      -- Business question from the brief: "what is the sales trend for
-- different seasons?" See macros/get_season.sql for the season
-- definition and the documented assumption behind it.

with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

product as (

    select * from "fashionable"."main_core"."dim_product"
    where is_current

),

joined as (

    select
        fct.season,
        extract(year from fct.order_date) as order_year,
        product.category,
        fct.is_cancelled,
        fct.quantity,
        fct.amount

    from fct
    left join product on fct.product_sk = product.product_sk

),

final as (

    select
        season,
        order_year,
        category,
        count(*)                                            as order_line_count,
        sum(case when not is_cancelled then quantity end)   as units_sold,
        sum(case when not is_cancelled then amount end)     as gross_revenue

    from joined
    group by 1, 2, 3

)

select * from final
    );
  
  