{#
    Cross-database day-of-week extraction.

    Different warehouses use different syntax/numbering for "day of week":
      - DuckDB / Postgres: EXTRACT(DOW FROM date) -> 0 (Sunday) .. 6 (Saturday)
      - BigQuery:          EXTRACT(DAYOFWEEK FROM date) -> 1 (Sunday) .. 7 (Saturday)

    This macro normalizes both to the same convention used across this
    project: 0 = Sunday .. 6 = Saturday.

    Usage: {{ day_of_week('session_date') }}
#}
{% macro day_of_week(date_column) -%}
    {%- if target.type == 'bigquery' -%}
        (extract(dayofweek from {{ date_column }}) - 1)
    {%- else -%}
        extract(dow from {{ date_column }})
    {%- endif -%}
{%- endmacro %}