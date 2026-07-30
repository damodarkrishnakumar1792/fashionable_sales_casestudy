-- Standard generated date dimension, not Type-2 (dates don't change).
-- Bounds are set generously around the observed order_date range;
-- Bounds are derived from the actual data min(order_date) from staging, and max(order_date) and some buffer

with date_bounds as (
    select 
        min(order_date)::date as min_date,
        (max(order_date) + interval '10 days')::date as max_date
    from {{ ref('stg_fashionable_sales') }}  
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
        {{ get_season('date_day') }}                        as season

    from spine

)

select * from final