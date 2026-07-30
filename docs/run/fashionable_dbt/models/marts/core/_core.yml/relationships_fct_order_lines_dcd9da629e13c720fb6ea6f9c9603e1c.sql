
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select ship_location_sk as from_field
    from "fashionable"."main_core"."fct_order_lines"
    where ship_location_sk is not null
),

parent as (
    select ship_location_sk as to_field
    from "fashionable"."main_core"."dim_ship_location"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test