
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select ship_city
from "fashionable"."main_marketing"."mart_sales_by_region"
where ship_city is null



  
  
      
    ) dbt_internal_test