
      
  
    
    

    create  table
      "fashionable"."snapshots"."dim_ship_location_snapshot"
  
    as (
      
    

    select *,
        md5(coalesce(cast(ship_postal_code as varchar ), '')
         || '|' || coalesce(cast(now()::timestamp as varchar ), '')
        ) as dbt_scd_id,
        now()::timestamp as dbt_updated_at,
        now()::timestamp as dbt_valid_from,
        
  
  coalesce(nullif(now()::timestamp, now()::timestamp), null)
  as dbt_valid_to
from (
        



-- unique_key is ship_postal_code (a more durable identifier than a composite of all four fields — if the key itself were derived from
-- the columns being change-tracked). 
-- ASSUMPTION: postal code is treated as 1:1 with a single city/state at any point in time but can be unknown or null as well
select distinct
    upper(trim(regexp_replace(ship_postal_code, '\.0$', ''))) as ship_postal_code,
    ship_city,
    ship_state,
    ship_country
from "fashionable"."main_staging"."stg_fashionable_sales"
where ship_postal_code is not null

    ) sbq



    );
  
  
  