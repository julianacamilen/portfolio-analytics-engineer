# Payments Funnel

Deposit and withdrawal conversion funnel: attempted transactions broken
down by outcome, plus the success rate derived from it. Built as a
public, synthetic-data companion to a real-world self-service analytics
stack (dbt + BigQuery). Full source on
[GitHub](https://github.com/julianacamilen/portfolio-analytics-engineer).

```sql payments_all
select * from bigquery.payments_daily
order by created_date
```

<DateRange
    name=date_filter
    data={payments_all}
    dates=created_date
    presetRanges={['Last 7 Days', 'Last 30 Days', 'Last 3 Months', 'All Time']}
/>

```sql deposits
select * from bigquery.payments_daily
where transaction_type = 'deposit'
  and created_date between '${inputs.date_filter.start}' and '${inputs.date_filter.end}'
order by created_date
```

```sql withdrawals
select * from bigquery.payments_daily
where transaction_type = 'withdrawal'
  and created_date between '${inputs.date_filter.start}' and '${inputs.date_filter.end}'
order by created_date
```

```sql summary
select
    transaction_type,
    sum(attempted)                                     as total_attempted,
    sum(successful)                                    as total_successful,
    round(100.0 * sum(successful) / sum(attempted), 2) as overall_success_rate_pct
from bigquery.payments_daily
where created_date between '${inputs.date_filter.start}' and '${inputs.date_filter.end}'
group by 1
```

## Deposits

<BigValue
    data={summary.where("transaction_type = 'deposit'")}
    value=total_attempted
    title="Deposits Attempted"
    fmt=num0
/>

<BigValue
    data={summary.where("transaction_type = 'deposit'")}
    value=overall_success_rate_pct
    title="Deposit Success Rate"
    fmt='#,##0.0"%"'
/>

<BarChart
    data={deposits}
    x=created_date
    y={['successful','failed','refunded','pending','cancelled']}
    y2=success_rate_pct
    y2SeriesType=line
    y2Fmt='#,##0"%"'
    title="Deposit Volume"
    subtitle="Attempted transactions by outcome, with success rate"
    yAxisTitle="Transactions"
    y2AxisTitle="Success Rate"
    colorPalette={['#9CAF88', '#C97C5D', '#D9A5B3', '#E3C16F', '#A69080', '#6B4F4F']}
/>

## Withdrawals

<BigValue
    data={summary.where("transaction_type = 'withdrawal'")}
    value=total_attempted
    title="Withdrawals Attempted"
    fmt=num0
/>

<BigValue
    data={summary.where("transaction_type = 'withdrawal'")}
    value=overall_success_rate_pct
    title="Withdrawal Success Rate"
    fmt='#,##0.0"%"'
/>

<BarChart
    data={withdrawals}
    x=created_date
    y={['successful','failed','refunded','pending','cancelled']}
    y2=success_rate_pct
    y2SeriesType=line
    y2Fmt='#,##0"%"'
    title="Withdrawal Volume"
    subtitle="Attempted transactions by outcome, with success rate"
    yAxisTitle="Transactions"
    y2AxisTitle="Success Rate"
    colorPalette={['#9CAF88', '#C97C5D', '#D9A5B3', '#E3C16F', '#A69080', '#6B4F4F']}
/>