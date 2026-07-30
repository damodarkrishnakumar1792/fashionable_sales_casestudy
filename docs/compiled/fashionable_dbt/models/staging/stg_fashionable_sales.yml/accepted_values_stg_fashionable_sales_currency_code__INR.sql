
    
    

with all_values as (

    select
        currency_code as value_field,
        count(*) as n_records

    from "fashionable"."main_staging"."stg_fashionable_sales"
    group by currency_code

)

select *
from all_values
where value_field not in (
    'INR'
)


