





with validation_errors as (

    select
        order_id
    from "fashionable"."main_marketing"."mart_order_summary"
    group by order_id
    having count(*) > 1

)

select *
from validation_errors


