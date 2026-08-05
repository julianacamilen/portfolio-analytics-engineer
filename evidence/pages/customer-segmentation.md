# Customer Segmentation

Customers grouped into value segments based on their total successful
deposit amount. Built as a public, synthetic-data companion to a
real-world self-service analytics stack (dbt + BigQuery). Full source on
[GitHub](https://github.com/julianacamilen/portfolio-analytics-engineer).

```sql segments
select * from bigquery.segment_summary
order by
    case value_segment
        when 'No Deposit' then 0
        when 'Bronze' then 1
        when 'Silver' then 2
        when 'Gold' then 3
        when 'Platinum' then 4
    end
```

```sql overview
select
    sum(customer_count) as total_customers,
    sum(case when value_segment != 'No Deposit' then customer_count end) as depositing_customers,
    sum(total_deposit_amount) as total_deposit_amount
from bigquery.segment_summary
```

<BigValue
    data={overview}
    value=total_customers
    title="Total Customers"
    fmt=num0
/>

<BigValue
    data={overview}
    value=depositing_customers
    title="Depositing Customers"
    fmt=num0
/>

<BigValue
    data={overview}
    value=total_deposit_amount
    title="Total Deposit Volume"
    fmt=usd0
/>

## Segment Distribution

All customers are included here, including those with zero successful
deposits (**No Deposit**) — not just depositing customers.

<BarChart
    data={segments}
    x=value_segment
    y=customer_count
    sort=false
    title="Customers by Segment"
    subtitle="Number of customers in each value segment, incl. No Deposit"
    yAxisTitle="Customers"
    colorPalette={['#A69080', '#C97C5D', '#E3C16F', '#9CAF88', '#6B4F4F']}
/>

## Value per Segment

<BarChart
    data={segments}
    x=value_segment
    y=avg_deposit_per_customer
    sort=false
    title="Average Deposit per Customer"
    subtitle="By segment (No Deposit customers average $0, by definition)"
    yAxisTitle="Avg. Deposit ($)"
    yFmt=usd0
    colorPalette={['#A69080', '#C97C5D', '#E3C16F', '#9CAF88', '#6B4F4F']}
/>

## Full Breakdown

All customer segments, including **No Deposit** (customers with zero
successful deposits so far).

<DataTable data={segments}>
    <Column id=value_segment title="Segment"/>
    <Column id=customer_count title="Customers" fmt=num0/>
    <Column id=pct_of_customers title="% of Base" fmt='#,##0.0"%"'/>
    <Column id=total_deposit_amount title="Total Deposits" fmt=usd0/>
    <Column id=avg_deposit_per_customer title="Avg. Deposit" fmt=usd0/>
</DataTable>