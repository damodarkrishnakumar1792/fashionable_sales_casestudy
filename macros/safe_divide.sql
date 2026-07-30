{% macro safe_divide(numerator, denominator) %}
    -- Guards mart-level ratio calculations (e.g. avg order value,
    -- cancellation rate) against divide-by-zero when a group has no
    -- qualifying rows.
    case
        when {{ denominator }} = 0 or {{ denominator }} is null then null
        else ({{ numerator }} * 1.0) / ({{ denominator }})
    end
{% endmacro %}
