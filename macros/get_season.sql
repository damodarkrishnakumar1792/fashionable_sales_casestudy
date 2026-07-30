{% macro get_season(date_column) %}
    -- US/European meteorological season definition (Northern Hemisphere):
    --   Winter: Dec, Jan, Feb | Spring: Mar, Apr, May
    --   Summer: Jun, Jul, Aug | Autumn: Sep, Oct, Nov
    -- ASSUMPTION FLAG: this dataset ships to India (ship-country = 'IN',
    -- currency = INR), where these seasons don't map to local retail
    -- seasonality (e.g. monsoon, festive season). This mapping was chosen
    -- explicitly per project decision, not because it's the best analytical
    -- fit for the underlying market — worth calling out in the presentation
    -- as a documented assumption rather than a data-driven choice.
    case
        when extract(month from {{ date_column }}) in (12, 1, 2) then 'Winter'
        when extract(month from {{ date_column }}) in (3, 4, 5) then 'Spring'
        when extract(month from {{ date_column }}) in (6, 7, 8) then 'Summer'
        when extract(month from {{ date_column }}) in (9, 10, 11) then 'Autumn'
    end
{% endmacro %}
