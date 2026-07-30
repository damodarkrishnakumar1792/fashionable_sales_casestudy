






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and quantity >= 0
)
 as expression


    from "fashionable"."main_staging"."stg_fashionable_sales"
    

),
validation_errors as (

    select
        *
    from
        grouped_expression
    where
        not(expression = true)

)

select *
from validation_errors







