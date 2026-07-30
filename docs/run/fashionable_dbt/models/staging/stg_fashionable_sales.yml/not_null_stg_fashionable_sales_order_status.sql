
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_status
from "fashionable"."main_staging"."stg_fashionable_sales"
where order_status is null



  
  
      
    ) dbt_internal_test