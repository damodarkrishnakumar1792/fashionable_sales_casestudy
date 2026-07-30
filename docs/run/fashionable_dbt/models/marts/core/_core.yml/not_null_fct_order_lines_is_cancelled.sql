
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select is_cancelled
from "fashionable"."main_core"."fct_order_lines"
where is_cancelled is null



  
  
      
    ) dbt_internal_test