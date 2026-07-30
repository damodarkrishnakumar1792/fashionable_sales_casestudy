
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select fulfilment
from "fashionable"."main_marketing"."mart_channel_performance"
where fulfilment is null



  
  
      
    ) dbt_internal_test