
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        ship_state, ship_city, category
    from "fashionable"."main_marketing"."mart_sales_by_region"
    group by ship_state, ship_city, category
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test