-- Type-2 SCD product dimension, sourced from the snapshot. Exposes full history (dbt_valid_from / dbt_valid_to) plus a convenience is_current
-- flag, so both point-in-time fact joins and "current state" reporting are supported from the same table.

with snapshot as (
    select * from {{ ref('dim_ship_location_snapshot') }}
),

deduplicated as (
    select *
    from snapshot
    qualify row_number() over (partition by ship_postal_code order by dbt_valid_from desc) = 1
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['ship_postal_code']) }} as ship_location_sk,
        ship_postal_code,
        ship_city,
        ship_state,
        ship_country,
        dbt_valid_from,
        dbt_valid_to,
        true as is_current
    from deduplicated

)

select * from final