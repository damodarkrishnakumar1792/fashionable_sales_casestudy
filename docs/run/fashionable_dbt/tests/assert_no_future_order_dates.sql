
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  -- Business-rule test: a sales order cannot legitimately be dated in the future. 
-- current_date is evaluated at query time, not compile time, so this
-- stays a meaningful check every time the pipeline is re-run, not just
-- a one-off snapshot of "future" relative to when this file was written.

select *
from "fashionable"."main_core"."fct_order_lines"
where order_date > current_date
  
  
      
    ) dbt_internal_test