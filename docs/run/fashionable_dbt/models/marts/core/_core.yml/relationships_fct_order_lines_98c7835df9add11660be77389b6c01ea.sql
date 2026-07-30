
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select order_date_key as from_field
    from "fashionable"."main_core"."fct_order_lines"
    where order_date_key is not null
),

parent as (
    select date_key as to_field
    from "fashionable"."main_core"."dim_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test