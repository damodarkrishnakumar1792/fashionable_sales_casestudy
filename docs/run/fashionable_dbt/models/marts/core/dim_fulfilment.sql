
  
    
    

    create  table
      "fashionable"."main_core"."dim_fulfilment__dbt_tmp"
  
    as (
      -- Kimball "junk dimension": bundles several low-cardinality flags/attributes
-- that would otherwise each need their own tiny FK dimension. Type 1 SCD with no history

with distinct_combos as (

    select distinct
        fulfilment,
        sales_channel,
        ship_service_level,
        courier_status,
        fulfilled_by,
        is_b2b
    from "fashionable"."main_intermediate"."int_sales_enriched"

),

final as (

    select
        md5(cast(coalesce(cast(fulfilment as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(sales_channel as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ship_service_level as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(courier_status as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(fulfilled_by as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(is_b2b as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fulfilment_sk,
        fulfilment,
        sales_channel,
        ship_service_level,
        courier_status,
        fulfilled_by,
        is_b2b

    from distinct_combos

)

select * from final
    );
  
  