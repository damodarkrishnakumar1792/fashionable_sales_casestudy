






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and amount >= 0
)
 as expression


    from "fashionable"."main_core"."fct_order_lines"
    

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







