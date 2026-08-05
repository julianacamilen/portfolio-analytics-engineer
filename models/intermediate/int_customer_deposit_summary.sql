-- One row per customer, with their total successful deposit amount and
-- count. This is the value signal used to assign a customer to a
-- segment.

with transactions as (

    select * from {{ ref('stg_transactions') }}
    where status = 'successful'
      and transaction_type = 'deposit'

),

customer_deposits as (

    select
        customer_id,
        sum(amount) as total_deposit_amount,
        count(*) as deposit_count

    from transactions
    group by 1

)

select * from customer_deposits