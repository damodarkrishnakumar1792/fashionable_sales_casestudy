





with validation_errors as (

    select
        ship_state, ship_city, category
    from "fashionable"."main_marketing"."mart_sales_by_region"
    group by ship_state, ship_city, category
    having count(*) > 1

)

select *
from validation_errors


