
    
    

with all_values as (

    select
        order_status as value_field,
        count(*) as n_records

    from "fashionable"."main_staging"."stg_fashionable_sales"
    group by order_status

)

select *
from all_values
where value_field not in (
    
)


