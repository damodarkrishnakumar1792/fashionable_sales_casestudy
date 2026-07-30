
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  





with validation_errors as (

    select
        order_id, sku, asin, courier_status
    from "fashionable"."main_staging"."stg_fashionable_sales"
    group by order_id, sku, asin, courier_status
    having count(*) > 1

)

select *
from validation_errors



  
  
      
    ) dbt_internal_test