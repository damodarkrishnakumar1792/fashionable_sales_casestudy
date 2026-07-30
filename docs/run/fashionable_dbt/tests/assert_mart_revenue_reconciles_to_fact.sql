
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  -- Singular test: total gross_revenue across mart_sales_by_region must
-- reconcile to total non-cancelled amount in fct_order_lines. This is a
-- direct SSOT check — if the mart's aggregation logic (or a future join
-- added to it) ever double-counts or drops rows, this catches it instead
-- of a marketer unknowingly presenting a wrong number.
-- Uses a small tolerance for floating point rounding, not exact equality.

with fact_total as (
    select sum(amount) as total_amount
    from "fashionable"."main_core"."fct_order_lines"
    where not is_cancelled
),

mart_total as (
    select sum(gross_revenue) as total_amount
    from "fashionable"."main_marketing"."mart_sales_by_region"
)

select
    fact_total.total_amount as fact_total_amount,
    mart_total.total_amount as mart_total_amount
from fact_total
cross join mart_total
where abs(coalesce(fact_total.total_amount, 0) - coalesce(mart_total.total_amount, 0)) > 0.01
  
  
      
    ) dbt_internal_test