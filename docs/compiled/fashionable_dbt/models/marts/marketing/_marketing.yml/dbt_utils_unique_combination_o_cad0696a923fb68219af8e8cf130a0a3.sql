





with validation_errors as (

    select
        category, ship_state, fulfilment
    from "fashionable"."main_marketing"."mart_cancellation_deep_dive"
    group by category, ship_state, fulfilment
    having count(*) > 1

)

select *
from validation_errors


