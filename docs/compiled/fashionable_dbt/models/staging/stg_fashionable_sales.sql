-- Grain: one row per order line, matching the raw source.
-- Structure: typed/renamed pass -> explicit cleaning step -> exact-duplicate
-- guard. Business rules (cancelled-order handling, derived fields, keys)
-- still materiazed data in the intermediate layer, view as of here.


with source as (

    select * from "fashionable"."main"."raw_sales"

),

typed as (

    select
        try_cast(trim("index") as integer)                     as source_row_index,
        trim(order_id)                                          as order_id,

        -- NOTE: date format assumed MM-DD-YY based on the original file
        cast(strptime(trim(date), '%m-%d-%y') as date)          as order_date,

        trim(status)                                            as order_status,
        trim(fulfilment)                                         as fulfilment,
        trim(sales_channel)                                      as sales_channel,
        trim(ship_service_level)                                  as ship_service_level,
        trim(style)                                               as style,
        trim(sku)                                                 as sku,
        trim(category)                                            as category,
        trim(size)                                                as size,
        trim(asin)                                                as asin,
        trim(courier_status)                                      as courier_status,

        try_cast(trim(qty) as integer)                           as quantity,
        trim(currency)                                            as currency_code,
        try_cast(nullif(trim(amount), '') as double)              as amount_raw,

        coalesce(nullif(trim(ship_city), ''), 'Unknown')           as ship_city_raw,
        coalesce(nullif(trim(ship_state), ''), 'Unknown')          as ship_state_raw,
        coalesce(nullif(trim(ship_postal_code), ''), 'Unknown')    as ship_postal_code,
        coalesce(nullif(trim(ship_country), ''), 'Unknown')        as ship_country_raw,
        trim(promotion)                                            as promotion_ids,
        case
            when lower(trim(b2b)) = 'true' then true
            when lower(trim(b2b)) = 'false' then false
            else false
        end                                                       as is_b2b,
        trim(fulfilled_by)                                          as fulfilled_by,

        current_timestamp                                        as _loaded_at,
        cast('2026-07-30 19:39:03' as timestamp) as _dbt_run_date

    from source

),

cleaned as (

    -- Explicit data-cleaning step. Kept separate from `typed` 
    select
        source_row_index,

        trim(order_id)                                         as order_id,
        trim(sku)                                               as sku,

        order_date,

        -- Order status/category/style values are trimmed
        trim(order_status)                                     as order_status,
        trim(fulfilment)                                        as fulfilment,
        trim(sales_channel)                                     as sales_channel,
        trim(ship_service_level)                                 as ship_service_level,
        trim(style)                                              as style,
        trim(category)                                           as category,
        trim(size)                                               as size,
        trim(asin)                                               as asin,
        trim(courier_status)                                     as courier_status,
        quantity,												-- Kept as NULL (not coerced to 0) so downstream averages/sums
        trim(currency_code)                                      as currency_code,

        -- Cancelled / zero-qty lines carry a blank amount in the source.
        case when quantity = 0 then null else amount_raw end   as amount,

        upper(trim(ship_city_raw))                              as ship_city,
		
		case
			when upper(trim(ship_state_raw)) in ('NL', 'NAGALAND') then 'NAGALAND'
			when upper(trim(ship_state_raw)) in ('ODISHA', 'ORISSA') then 'ODISHA'
			when upper(trim(ship_state_raw)) in ('PONDICHERRY', 'PUDUCHERRY') then 'PONDICHERRY'
			when upper(trim(ship_state_raw)) in ('PB', 'PUNJAB', 'PUNJAB/MOHALI/ZIRAKPUR') then 'PUNJAB'
			when upper(trim(ship_state_raw)) in ('RAJASTHAN', 'RAJSHTHAN', 'RAJSTHAN', 'RJ') then 'RAJASTHAN'
			when upper(trim(ship_state_raw)) in ('ANDHRA PRADESH', 'APO') then 'ANDHRA PRADESH'
			when upper(trim(ship_state_raw)) in ('AR', 'ARUNACHAL PRADESH') then 'ARUNACHAL PRADESH'
			else upper(trim(ship_state_raw))
		end as ship_state,

        upper(trim(ship_country_raw))                            as ship_country,

        upper(trim(regexp_replace(ship_postal_code, '\.0$', '')))	as ship_postal_code	,
        trim(promotion_ids)                                      as promotion_ids,
        is_b2b,
        trim(fulfilled_by)                                       as fulfilled_by,
        _loaded_at,
        _dbt_run_date

    from typed

),

deduped as (

    -- Exact-duplicate guard: if the source ever contains two fully
    -- identical rows (a known real-world CSV export issue.This does NOT touch legitimate (order_id, sku) pairs 
    select
        *,
        row_number() over (
            partition by
                order_id, sku, order_date, order_status, fulfilment,
                sales_channel, ship_service_level, style, category, size,
                asin, courier_status, quantity, currency_code, amount,
                ship_city, ship_state, ship_postal_code, ship_country,
                promotion_ids, is_b2b, fulfilled_by
            order by source_row_index
        ) as _dedup_row_num
    from cleaned

)

select
    source_row_index, order_id, order_date, order_status, fulfilment,
    sales_channel, ship_service_level, style, sku, category, size, asin,
    courier_status, quantity, currency_code, amount, ship_city, ship_state,
    ship_postal_code, ship_country, promotion_ids, is_b2b, fulfilled_by,
    _loaded_at, _dbt_run_date
from deduped
where _dedup_row_num = 1