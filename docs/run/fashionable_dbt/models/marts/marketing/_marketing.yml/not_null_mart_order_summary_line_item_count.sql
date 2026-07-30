
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select line_item_count
from "fashionable"."main_marketing"."mart_order_summary"
where line_item_count is null



  
  
      
    ) dbt_internal_test