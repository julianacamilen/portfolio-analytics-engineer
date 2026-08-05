{#
    Cross-database difference between two dates, in whole months.

    - DuckDB / Postgres: DATE_DIFF('month', start_date, end_date)  -- part first, then start, then end
    - BigQuery:          DATE_DIFF(end_date, start_date, MONTH)    -- end first, then start, then part

    Usage: {{ months_between('cohort_month', 'activity_month') }}
    Returns: number of months between start_date and end_date (end - start).
#}
{% macro months_between(start_date, end_date) -%}
    {%- if target.type == 'bigquery' -%}
        date_diff({{ end_date }}, {{ start_date }}, month)
    {%- else -%}
        date_diff('month', {{ start_date }}, {{ end_date }})
    {%- endif -%}
{%- endmacro %}