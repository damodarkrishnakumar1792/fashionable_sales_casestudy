





with validation_errors as (

    select
        order_year, order_month, category
    from "fashionable"."main_marketing"."mart_monthly_trends"
    group by order_year, order_month, category
    having count(*) > 1

)

select *
from validation_errors


