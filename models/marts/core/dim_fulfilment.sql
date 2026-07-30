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
    from {{ ref('int_sales_enriched') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['fulfilment', 'sales_channel', 'ship_service_level', 'courier_status', 'fulfilled_by', 'is_b2b']) }} as fulfilment_sk,
        fulfilment,
        sales_channel,
        ship_service_level,
        courier_status,
        fulfilled_by,
        is_b2b

    from distinct_combos

)

select * from final
