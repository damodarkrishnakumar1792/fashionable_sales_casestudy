-- Singular test: enforces the specific business rule from the staging
-- model's design (cancelled lines ->  0).
-- A dbt test fails if this query returns any rows.

select *
from "fashionable"."main_core"."fct_order_lines"
where is_cancelled
  and amount < 0