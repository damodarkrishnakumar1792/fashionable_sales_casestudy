
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select fulfilment_key
from "fashionable"."main_intermediate"."int_sales_enriched"
where fulfilment_key is null



  
  
      
    ) dbt_internal_test