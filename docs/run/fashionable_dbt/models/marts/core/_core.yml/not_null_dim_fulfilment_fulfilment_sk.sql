
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select fulfilment_sk
from "fashionable"."main_core"."dim_fulfilment"
where fulfilment_sk is null



  
  
      
    ) dbt_internal_test