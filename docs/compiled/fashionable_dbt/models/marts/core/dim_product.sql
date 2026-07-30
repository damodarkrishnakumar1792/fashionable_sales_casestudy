-- Type-2 SCD product dimension, sourced from the snapshot. Exposes full history (dbt_valid_from / dbt_valid_to) plus a convenience is_current
-- flag, so both point-in-time fact joins and "current state" reporting are supported from the same table.

with snapshot as (

    select * from "fashionable"."snapshots"."dim_product_snapshot"

),

deduplicated as (

    -- Pick exactly 1 row per SKU: the most recent/current one
    select *
    from snapshot
    qualify row_number() over (partition by sku order by dbt_valid_from desc) = 1

),

final as (

    select
        md5(cast(coalesce(cast(sku as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as product_sk,
        sku,
        style,
        category,
        size,
        asin,
        dbt_valid_from,
        dbt_valid_to,
        true as is_current   -- always true since we only keep current rows

    from deduplicated

)

select * from final