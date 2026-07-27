{% test accepted_range(model, column_name, min_value=none, max_value=none) %}
{#
    Custom generic test (does not depend on the dbt_utils package).
    Fails if any value in the column is outside [min_value, max_value].
    Usage in schema.yml:
        tests:
          - accepted_range:
              arguments:
                min_value: 0
                max_value: 100
#}

select *
from {{ model }}
where
    {{ column_name }} is not null
    {% if min_value is not none %}
    and {{ column_name }} < {{ min_value }}
    {% endif %}
    {% if max_value is not none %}
    and {{ column_name }} > {{ max_value }}
    {% endif %}

{% endtest %}