
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select size
from "fashionable"."main_marketing"."mart_size_performance"
where size is null



  
  
      
    ) dbt_internal_test