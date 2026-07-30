
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_month
from "fashionable"."main_marketing"."mart_monthly_trends"
where order_month is null



  
  
      
    ) dbt_internal_test