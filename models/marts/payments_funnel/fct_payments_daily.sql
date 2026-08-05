-- Grain: 1 row per (date, transaction_type).
-- Equivalent to the "Deposit Volume" and "Withdrawal Volume" charts from
-- the original dashboard: a funnel of attempted -> successful/failed/
-- refunded/pending/cancelled, plus the rates derived from it.

with transactions as (

    select * from {{ ref('stg_transactions') }}

),

daily as (

    select
        created_date,
        transaction_type,

        count(*)                                                     as attempted,
        count(case when status = 'successful' then 1 end)             as successful,
        count(case when status = 'failed' then 1 end)                 as failed,
        count(case when status = 'refunded' then 1 end)                as refunded,
        count(case when status = 'pending' then 1 end)                 as pending,
        count(case when status = 'cancelled' then 1 end)               as cancelled,

        sum(case when status = 'successful' then amount else 0 end)   as successful_amount,

        round(
            100.0 * count(case when status = 'successful' then 1 end) / count(*), 2
        )                                                              as success_rate_pct,

        round(
            100.0 * count(case when status = 'failed' then 1 end) / count(*), 2
        )                                                              as rejection_rate_pct,

        round(
            100.0 * count(case when status = 'cancelled' then 1 end) / count(*), 2
        )                                                              as cancellation_rate_pct

    from transactions
    group by 1, 2

)

select * from daily
order by created_date, transaction_type