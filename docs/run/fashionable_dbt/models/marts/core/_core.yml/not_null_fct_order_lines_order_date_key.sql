
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_date_key
from "fashionable"."main_core"."fct_order_lines"
where order_date_key is null



  
  
      
    ) dbt_internal_test