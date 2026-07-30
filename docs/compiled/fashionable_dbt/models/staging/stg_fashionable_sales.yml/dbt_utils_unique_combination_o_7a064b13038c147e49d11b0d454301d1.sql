





with validation_errors as (

    select
        order_id, sku, asin, courier_status
    from "fashionable"."main_staging"."stg_fashionable_sales"
    group by order_id, sku, asin, courier_status
    having count(*) > 1

)

select *
from validation_errors


