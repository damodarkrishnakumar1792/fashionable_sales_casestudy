
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sku
from "fashionable"."main_core"."dim_product"
where sku is null



  
  
      
    ) dbt_internal_test