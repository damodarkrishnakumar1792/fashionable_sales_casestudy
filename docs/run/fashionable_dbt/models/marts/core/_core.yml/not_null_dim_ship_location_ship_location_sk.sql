
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select ship_location_sk
from "fashionable"."main_core"."dim_ship_location"
where ship_location_sk is null



  
  
      
    ) dbt_internal_test