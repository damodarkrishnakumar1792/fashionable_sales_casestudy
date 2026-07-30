
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    order_line_key as unique_field,
    count(*) as n_records

from "fashionable"."main_intermediate"."int_sales_enriched"
where order_line_key is not null
group by order_line_key
having count(*) > 1



  
  
      
    ) dbt_internal_test