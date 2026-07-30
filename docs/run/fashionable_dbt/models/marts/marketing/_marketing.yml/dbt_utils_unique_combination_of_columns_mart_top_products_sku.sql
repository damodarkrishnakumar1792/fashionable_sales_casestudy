
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        sku
    from "fashionable"."main_marketing"."mart_top_products"
    group by sku
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test