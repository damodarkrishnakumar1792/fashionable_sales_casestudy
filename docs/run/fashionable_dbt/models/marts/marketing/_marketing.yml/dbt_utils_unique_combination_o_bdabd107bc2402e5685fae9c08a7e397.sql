
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        season, order_year, category
    from "fashionable"."main_marketing"."mart_seasonal_trends"
    group by season, order_year, category
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test