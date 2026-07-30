





with validation_errors as (

    select
        season, order_year, category
    from "fashionable"."main_marketing"."mart_seasonal_trends"
    group by season, order_year, category
    having count(*) > 1

)

select *
from validation_errors


