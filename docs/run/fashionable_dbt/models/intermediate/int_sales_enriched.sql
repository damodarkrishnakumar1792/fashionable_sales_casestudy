
  
    
    

    create  table
      "fashionable"."main_intermediate"."int_sales_enriched__dbt_tmp"
  
    as (
      -- Grain: one row per order line (order_id + sku + asin + courier_status) which is unchanged from staging.
-- Business logic here so staging stays a typed pass-through.

with stg_sales as (

    select * from "fashionable"."main_staging"."stg_fashionable_sales"

),

enriched as (

    select
        *,
        
    -- US/European meteorological season definition (Northern Hemisphere):
    --   Winter: Dec, Jan, Feb | Spring: Mar, Apr, May
    --   Summer: Jun, Jul, Aug | Autumn: Sep, Oct, Nov
    -- ASSUMPTION FLAG: this dataset ships to India (ship-country = 'IN',
    -- currency = INR), where these seasons don't map to local retail
    -- seasonality (e.g. monsoon, festive season). This mapping was chosen
    -- explicitly per project decision, not because it's the best analytical
    -- fit for the underlying market — worth calling out in the presentation
    -- as a documented assumption rather than a data-driven choice.
    case
        when extract(month from order_date) in (12, 1, 2) then 'Winter'
        when extract(month from order_date) in (3, 4, 5) then 'Spring'
        when extract(month from order_date) in (6, 7, 8) then 'Summer'
        when extract(month from order_date) in (9, 10, 11) then 'Autumn'
    end
 as season,

        case
            when order_status = 'Cancelled' then true
            else false
        end as is_cancelled,

        md5(cast(coalesce(cast(order_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(sku as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(asin as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(courier_status as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as order_line_key,

        -- 'sku' is treated as the durable natural key for the Type-2 SCD dim_product snapshot.
        sku as product_natural_key,

        -- Matches the unique_key used in dim_ship_location_snapshot so the fact table can join to it directly.
        ship_postal_code as ship_location_natural_key,
        md5(cast(coalesce(cast(fulfilment as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(sales_channel as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ship_service_level as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(courier_status as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(fulfilled_by as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(is_b2b as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as fulfilment_key

    from stg_sales

)

select * from enriched
    );
  
  