
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        order_year, order_month, category
    from "fashionable"."main_marketing"."mart_monthly_trends"
    group by order_year, order_month, category
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test