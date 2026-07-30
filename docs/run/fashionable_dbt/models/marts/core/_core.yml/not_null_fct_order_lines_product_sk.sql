
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select product_sk
from "fashionable"."main_core"."fct_order_lines"
where product_sk is null



  
  
      
    ) dbt_internal_test