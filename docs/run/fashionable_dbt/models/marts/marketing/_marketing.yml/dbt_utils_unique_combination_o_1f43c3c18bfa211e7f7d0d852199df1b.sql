
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        day_of_week_num
    from "fashionable"."main_marketing"."mart_weekday_performance"
    group by day_of_week_num
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test