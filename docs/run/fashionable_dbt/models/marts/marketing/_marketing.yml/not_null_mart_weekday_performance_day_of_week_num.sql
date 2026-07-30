
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select day_of_week_num
from "fashionable"."main_marketing"."mart_weekday_performance"
where day_of_week_num is null



  
  
      
    ) dbt_internal_test