
    
    

with child as (
    select fulfilment_sk as from_field
    from "fashionable"."main_core"."fct_order_lines"
    where fulfilment_sk is not null
),

parent as (
    select fulfilment_sk as to_field
    from "fashionable"."main_core"."dim_fulfilment"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


