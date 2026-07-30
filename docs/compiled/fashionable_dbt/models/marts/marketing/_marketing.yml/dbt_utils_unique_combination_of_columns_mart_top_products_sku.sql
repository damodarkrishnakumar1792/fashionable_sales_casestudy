





with validation_errors as (

    select
        sku
    from "fashionable"."main_marketing"."mart_top_products"
    group by sku
    having count(*) > 1

)

select *
from validation_errors


