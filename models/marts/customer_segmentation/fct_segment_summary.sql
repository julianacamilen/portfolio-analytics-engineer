-- Grain: 1 row per value segment.
-- Equivalent to "Segment Distribution" and "Average Deposit per Segment"
-- from the original dashboard.

with segmentation as (

    select * from {{ ref('fct_customer_segmentation') }}

),

by_segment as (

    select
        value_segment,
        count(*) as customer_count,
        sum(total_deposit_amount) as total_deposit_amount,
        round(avg(total_deposit_amount), 2) as avg_deposit_per_customer,
        round(
            100.0 * count(*) / sum(count(*)) over (), 2
        ) as pct_of_customers

    from segmentation
    group by 1

)

select * from by_segment
order by
    case value_segment
        when 'No Deposit' then 0
        when 'Bronze' then 1
        when 'Silver' then 2
        when 'Gold' then 3
        when 'Platinum' then 4
    end