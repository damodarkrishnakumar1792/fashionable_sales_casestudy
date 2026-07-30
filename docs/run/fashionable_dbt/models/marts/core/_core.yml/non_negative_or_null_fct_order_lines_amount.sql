
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
-- Generic/reusable custom test: fails on any row where the column is
-- both non-null and negative. Passes on null (nulls are meaningful here,
-- e.g. amount is null for cancelled lines by design).

select *
from "fashionable"."main_core"."fct_order_lines"
where amount is not null
  and amount < 0


  
  
      
    ) dbt_internal_test