-- One row per (customer, month) in which the customer had at least one
-- successful transaction. This is the activity signal used to measure
-- retention -- a customer counts as "retained" in a given month if they
-- show up here.

with transactions as (

    select * from {{ ref('stg_transactions') }}
    where status = 'successful'

),

monthly_activity as (

    select
        customer_id,
        {{ date_trunc_month('created_date') }} as activity_month

    from transactions
    group by 1, 2

)

select * from monthly_activity