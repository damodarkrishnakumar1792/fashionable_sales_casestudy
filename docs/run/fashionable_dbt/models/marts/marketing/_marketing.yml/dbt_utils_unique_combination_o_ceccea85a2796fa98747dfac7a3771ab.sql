
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        order_id
    from "fashionable"."main_marketing"."mart_order_summary"
    group by order_id
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test