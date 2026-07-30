
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select distinct_order_count
from "fashionable"."main_marketing"."mart_location_repeat_activity"
where distinct_order_count is null



  
  
      
    ) dbt_internal_test