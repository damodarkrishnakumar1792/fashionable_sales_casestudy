
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select category
from "fashionable"."main_marketing"."mart_promotion_performance"
where category is null



  
  
      
    ) dbt_internal_test