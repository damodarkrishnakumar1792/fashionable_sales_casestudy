





with validation_errors as (

    select
        category, style, size
    from "fashionable"."main_marketing"."mart_sales_by_category_style"
    group by category, style, size
    having count(*) > 1

)

select *
from validation_errors


