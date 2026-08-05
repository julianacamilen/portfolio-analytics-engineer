{#
    Cross-database month truncation.

    - DuckDB / Postgres: DATE_TRUNC('month', date)   -- part as a quoted string, first argument
    - BigQuery:          DATE_TRUNC(date, MONTH)      -- part as an unquoted keyword, second argument

    Usage: {{ date_trunc_month('signup_date') }}
#}
{% macro date_trunc_month(date_column) -%}
    {%- if target.type == 'bigquery' -%}
        date_trunc({{ date_column }}, month)
    {%- else -%}
        date_trunc('month', {{ date_column }})
    {%- endif -%}
{%- endmacro %}