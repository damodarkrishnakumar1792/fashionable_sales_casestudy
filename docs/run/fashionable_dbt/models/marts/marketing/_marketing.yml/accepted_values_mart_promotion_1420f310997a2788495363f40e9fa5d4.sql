
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        has_promotion as value_field,
        count(*) as n_records

    from "fashionable"."main_marketing"."mart_promotion_performance"
    group by has_promotion

)

select *
from all_values
where value_field not in (
    'True','False'
)



  
  
      
    ) dbt_internal_test