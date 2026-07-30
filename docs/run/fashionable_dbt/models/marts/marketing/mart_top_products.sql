
  
    
    

    create  table
      "fashionable"."main_marketing"."mart_top_products__dbt_tmp"
  
    as (
      -- Business question: "what are our best/worst-selling products?" 
-- Grain: one row per SKU.

with fct as (

    select * from "fashionable"."main_core"."fct_order_lines"

),

product as (

    select * from "fashionable"."main_core"."dim_product"
    where is_current

),

joined as (

    select
        product.sku,
        product.style,
        product.category,
        product.size,
        fct.is_cancelled,
        fct.quantity,
        fct.amount

    from fct
    left join product on fct.product_sk = product.product_sk

),

aggregated as (

    select
        sku,
        style,
        category,
        size,
        count(*)                                              as order_line_count,
        sum(case when not is_cancelled then quantity end)     as units_sold,
        sum(case when not is_cancelled then amount end)       as gross_revenue,
        
    -- Guards mart-level ratio calculations (e.g. avg order value,
    -- cancellation rate) against divide-by-zero when a group has no
    -- qualifying rows.
    case
        when sum(case when not is_cancelled then quantity end) = 0 or sum(case when not is_cancelled then quantity end) is null then null
        else (sum(case when not is_cancelled then amount end) * 1.0) / (sum(case when not is_cancelled then quantity end))
    end
 as avg_price_per_unit,
        
    -- Guards mart-level ratio calculations (e.g. avg order value,
    -- cancellation rate) against divide-by-zero when a group has no
    -- qualifying rows.
    case
        when count(*) = 0 or count(*) is null then null
        else (sum(case when is_cancelled then 1 else 0 end) * 1.0) / (count(*))
    end
 as cancellation_rate

    from joined
    group by sku, style, category, size

),

final as (

    select
        *,
        -- Rank nulls (SKUs with zero non-cancelled revenue) last, not
        -- first, via coalesce — a SKU with no confirmed sales shouldn't
        -- outrank one with real revenue just because null sorts first.
        row_number() over (order by coalesce(gross_revenue, 0) desc) as revenue_rank

    from aggregated

)

select * from final
    );
  
  