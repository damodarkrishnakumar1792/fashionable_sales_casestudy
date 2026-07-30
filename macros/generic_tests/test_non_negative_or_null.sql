{% test non_negative_or_null(model, column_name) %}
-- Generic/reusable custom test: fails on any row where the column is
-- both non-null and negative. Passes on null (nulls are meaningful here,
-- e.g. amount is null for cancelled lines by design).

select *
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} < 0

{% endtest %}
