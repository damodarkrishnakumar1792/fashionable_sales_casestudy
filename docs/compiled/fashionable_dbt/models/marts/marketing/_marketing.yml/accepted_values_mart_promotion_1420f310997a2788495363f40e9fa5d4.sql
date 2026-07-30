
    
    

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


