
    
    

select
    ship_location_sk as unique_field,
    count(*) as n_records

from "fashionable"."main_core"."dim_ship_location"
where ship_location_sk is not null
group by ship_location_sk
having count(*) > 1


