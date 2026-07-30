
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  -- Singular test: fct_order_lines must have exactly one row per row in
-- int_sales_enriched. The point-in-time joins to dim_product and
-- dim_ship_location (on order_date falling within a validity window) are
-- the riskiest part of this pipeline — if a date range ever overlapped
-- (e.g. a snapshot bug produced two "current" versions at once), a
-- LEFT JOIN would silently duplicate fact rows and overstate every
-- downstream sum. This test catches that directly instead of hoping the
-- join logic is right.
--
-- NOTE: fct_order_lines is now incremental. This test still holds under
-- the append-only assumption documented in that model , each run only adds rows newer than what's already there, so the accumulated total
-- should still equal the full source count. If that assumption breaks
-- (e.g. late-arriving historical corrections), this test would need to be revisited alongside the incremental watermark logic and further upgrades.

with source_count as (
    select count(*) as row_count
    from "fashionable"."main_intermediate"."int_sales_enriched"
),

fact_count as (
    select count(*) as row_count
    from "fashionable"."main_core"."fct_order_lines"
)

select
    source_count.row_count as source_row_count,
    fact_count.row_count   as fact_row_count
from source_count
cross join fact_count
where source_count.row_count != fact_count.row_count
  
  
      
    ) dbt_internal_test