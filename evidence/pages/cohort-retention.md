# Cohort Retention

How well customers keep coming back after signing up, grouped by the
month they were acquired. Each row is an acquisition cohort; each
column is how many months have passed since signup. Built as a public,
synthetic-data companion to a real-world self-service analytics stack
(dbt + BigQuery). Full source on
[GitHub](https://github.com/julianacamilen/portfolio-analytics-engineer).

```sql cohort
select
    strftime(cohort_month, '%Y-%m') as cohort_label,
    cohort_month,
    months_since_cohort,
    'Month ' || cast(months_since_cohort as integer)::varchar as months_since_label,    active_customers,
    cohort_size,
    retention_pct
from bigquery.cohort_retention
order by cohort_month, months_since_cohort
```

```sql cohort_summary
select
    count(distinct cohort_month) as total_cohorts,
    sum(case when months_since_cohort = 0 then cohort_size end) as total_customers,
    avg(case when months_since_cohort = 1 then retention_pct end) as avg_month1_retention
from bigquery.cohort_retention
```

<BigValue
    data={cohort_summary}
    value=total_cohorts
    title="Acquisition Cohorts"
    fmt=num0
/>

<BigValue
    data={cohort_summary}
    value=total_customers
    title="Total Customers"
    fmt=num0
/>

<BigValue
    data={cohort_summary}
    value=avg_month1_retention
    title="Avg. Month-1 Retention"
    fmt='#,##0.0"%"'
/>

## Retention Heatmap

<Heatmap
    data={cohort}
    x=months_since_label
    y=cohort_label
    value=retention_pct
    valueFmt='#,##0"%"'
    title="Retention % by Cohort"
    subtitle="Row = signup month, column = months since signup"
    colorScale={['#FEE9E1', '#E8590C']}
    xSort=months_since_cohort
    ySort=cohort_month
    ySortOrder=desc
    xAxisPosition=top
/>

## Cohort Sizes

<DataTable data={cohort.where('months_since_cohort = 0')} rows=10>
    <Column id=cohort_label title="Cohort"/>
    <Column id=cohort_size title="Customers Acquired" fmt=num0/>
</DataTable>