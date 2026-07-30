
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select category
from "fashionable"."main_marketing"."mart_sales_by_category_style"
where category is null



  
  
      
    ) dbt_internal_test