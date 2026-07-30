
    
    

select
    ship_location_natural_key as unique_field,
    count(*) as n_records

from "fashionable"."main_intermediate"."int_sales_enriched"
where ship_location_natural_key is not null
group by ship_location_natural_key
having count(*) > 1


