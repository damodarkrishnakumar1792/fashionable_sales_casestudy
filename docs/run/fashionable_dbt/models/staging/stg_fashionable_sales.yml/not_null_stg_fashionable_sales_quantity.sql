
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select quantity
from "fashionable"."main_staging"."stg_fashionable_sales"
where quantity is null



  
  
      
    ) dbt_internal_test