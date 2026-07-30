
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        ship_postal_code
    from "fashionable"."main_marketing"."mart_location_repeat_activity"
    group by ship_postal_code
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test