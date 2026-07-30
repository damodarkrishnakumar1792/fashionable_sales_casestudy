
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select revenue_rank
from "fashionable"."main_marketing"."mart_top_products"
where revenue_rank is null



  
  
      
    ) dbt_internal_test