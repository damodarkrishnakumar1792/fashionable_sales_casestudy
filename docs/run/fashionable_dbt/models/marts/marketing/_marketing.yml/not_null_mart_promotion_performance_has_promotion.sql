
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select has_promotion
from "fashionable"."main_marketing"."mart_promotion_performance"
where has_promotion is null



  
  
      
    ) dbt_internal_test