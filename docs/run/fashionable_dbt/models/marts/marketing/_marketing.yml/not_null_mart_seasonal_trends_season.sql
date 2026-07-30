
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select season
from "fashionable"."main_marketing"."mart_seasonal_trends"
where season is null



  
  
      
    ) dbt_internal_test