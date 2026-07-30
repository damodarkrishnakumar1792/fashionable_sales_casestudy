-- Standard generated date dimension, not Type-2 (dates don't change).
-- Bounds are set generously around the observed order_date range;
-- Bounds are derived from the actual data min(order_date) from staging, and max(order_date) and some buffer

with date_bounds as (
    select 
        min(order_date)::date as min_date,
        (max(order_date) + interval '10 days')::date as max_date
    from "fashionable"."main_staging"."stg_fashionable_sales"  
),

spine as (
    select generate_series as date_day
    from date_bounds,
    generate_series(min_date, max_date, interval '1 day')
),

final as (
    select
        cast(date_day as date)                              as date_day,
        strftime(date_day, '%Y%m%d')::int                   as date_key,
        extract(year from date_day)                         as year,
        extract(month from date_day)                        as month,
        extract(day from date_day)                          as day_of_month,
        extract(dow from date_day)                          as day_of_week,
        extract(quarter from date_day)                      as quarter,
        
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
        when extract(month from date_day) in (12, 1, 2) then 'Winter'
        when extract(month from date_day) in (3, 4, 5) then 'Spring'
        when extract(month from date_day) in (6, 7, 8) then 'Summer'
        when extract(month from date_day) in (9, 10, 11) then 'Autumn'
    end
                        as season

    from spine

)

select * from final