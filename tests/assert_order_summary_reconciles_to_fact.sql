-- SSOT reconciliation test, for mart_order_summary (the order-grain mart) rather than mart_sales_by_region.
-- total order_total_amount across mart_order_summary must tie back exactly to total non-cancelled amount in fct_order_lines. 
-- If the order-level rollup logic in mart_order_summary ever double-counts a line item or drops one, this test catches it directly instead of a marketer
-- unknowingly presenting a wrong average-order-value figure.
-- Uses a small tolerance for floating point rounding, not exact equality.

with fact_total as (
    select sum(amount) as total_amount
    from {{ ref('fct_order_lines') }}
    where not is_cancelled
),

mart_total as (
    select sum(order_total_amount) as total_amount
    from {{ ref('mart_order_summary') }}
)

select
    fact_total.total_amount as fact_total_amount,
    mart_total.total_amount as mart_total_amount
from fact_total
cross join mart_total
where abs(coalesce(fact_total.total_amount, 0) - coalesce(mart_total.total_amount, 0)) > 0.01