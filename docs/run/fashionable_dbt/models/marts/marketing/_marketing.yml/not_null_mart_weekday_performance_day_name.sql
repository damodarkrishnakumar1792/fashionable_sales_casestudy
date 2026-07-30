
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select day_name
from "fashionable"."main_marketing"."mart_weekday_performance"
where day_name is null



  
  
      
    ) dbt_internal_test