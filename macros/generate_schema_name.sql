{#
    Overrides dbt's default schema-naming behavior so that the +schema
    config set per folder (staging/intermediate/core/marketing) is used
    as a suffix on the target schema, e.g. `dbt_yourname_marketing`,
    rather than replacing it outright.

    This is dbt's own documented pattern for custom schema names — verify
    it still matches current dbt-core docs for your installed version
    before relying on it, since default macro internals can change
    across major versions.
#}

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
