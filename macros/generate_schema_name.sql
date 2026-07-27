{#
    By default, dbt generates schema names as "<target_schema>_<custom_schema>"
    (e.g. "main_raw"). To keep schemas clean and predictable across this
    portfolio project (raw / staging / marts), this override uses the
    custom_schema directly when its set.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is none -%}

        {{ target.schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}