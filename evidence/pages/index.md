# Web Engagement Analytics

Site engagement and traffic metrics for a fictional web platform — session
volume, duration, and bounce rate, plus the traffic windows with the
lowest activity. Built as a public, synthetic-data companion to a
real-world self-service analytics stack (dbt + BigQuery). Full source on
[GitHub](https://github.com/julianacamilen/portfolio-analytics-engineer).

```sql daily
select * from bigquery.sessions_daily
order by session_date
```

```sql summary
select
    sum(session_count)        as total_sessions,
    avg(avg_session_minutes)  as avg_session_minutes,
    avg(bounce_rate_pct)      as avg_bounce_rate_pct
from bigquery.sessions_daily
```

<BigValue
    data={summary}
    value=total_sessions
    title="Total Sessions"
    fmt=num0
/>

<BigValue
    data={summary}
    value=avg_session_minutes
    title="Avg. Session Duration"
    fmt='#,##0.0" min"'
/>

<BigValue
    data={summary}
    value=avg_bounce_rate_pct
    title="Avg. Bounce Rate"
    fmt='#,##0.0"%"'
/>

## Engagement Over Time

<LineChart
    data={daily}
    x=session_date
    y=session_count
    title="Daily Sessions"
    subtitle="Total sessions started per day"
    yAxisTitle="Sessions"
    colorPalette={['#4C6EF5']}
/>

<LineChart
    data={daily}
    x=session_date
    y=avg_session_minutes
    title="Average Session Duration"
    subtitle="Minutes per session, daily average"
    yAxisTitle="Minutes"
    colorPalette={['#12B886']}
/>

## Quietest Traffic Windows

The ten (day of week, hour) combinations with the lowest average
traffic — useful context for scheduling maintenance windows or
deployments with minimal user impact.

```sql hourly
select * from bigquery.sessions_hourly
order by avg_sessions asc
limit 10
```

<DataTable data={hourly} rows=10>
    <Column id=day_name title="Day"/>
    <Column id=session_hour title="Hour" fmt=num0/>
    <Column id=avg_sessions title="Avg. Sessions" fmt='#,##0.0'/>
</DataTable>