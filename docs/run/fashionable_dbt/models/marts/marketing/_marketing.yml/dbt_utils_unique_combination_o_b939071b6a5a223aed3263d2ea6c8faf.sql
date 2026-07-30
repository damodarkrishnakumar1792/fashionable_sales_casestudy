
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        fulfilment, sales_channel, ship_service_level, is_b2b
    from "fashionable"."main_marketing"."mart_channel_performance"
    group by fulfilment, sales_channel, ship_service_level, is_b2b
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test