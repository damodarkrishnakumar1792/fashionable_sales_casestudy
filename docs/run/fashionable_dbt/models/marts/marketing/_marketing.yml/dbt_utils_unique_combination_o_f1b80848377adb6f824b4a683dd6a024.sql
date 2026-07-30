
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        category, size
    from "fashionable"."main_marketing"."mart_size_performance"
    group by category, size
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test