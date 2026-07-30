
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        order_fulfillment_status as value_field,
        count(*) as n_records

    from "fashionable"."main_marketing"."mart_order_summary"
    group by order_fulfillment_status

)

select *
from all_values
where value_field not in (
    'Fully Cancelled','Partially Cancelled','Completed'
)



  
  
      
    ) dbt_internal_test