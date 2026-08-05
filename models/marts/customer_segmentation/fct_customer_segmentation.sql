-- Grain: 1 row per customer.
-- Assigns every customer to a value segment based on their total
-- successful deposit amount. Customers with zero successful deposits
-- (never converted) get their own segment rather than being excluded.

with customers as (

    select * from {{ ref('stg_customers') }}

),

deposits as (

    select * from {{ ref('int_customer_deposit_summary') }}

),

joined as (

    select
        customers.customer_id,
        customers.signup_date,
        customers.acquisition_channel,
        customers.country,
        coalesce(deposits.total_deposit_amount, 0) as total_deposit_amount,
        coalesce(deposits.deposit_count, 0)        as deposit_count

    from customers
    left join deposits
        on customers.customer_id = deposits.customer_id

),

segmented as (

    select
        *,
        case
            when total_deposit_amount = 0 then 'No Deposit'
            when total_deposit_amount < 100 then 'Bronze'
            when total_deposit_amount < 500 then 'Silver'
            when total_deposit_amount < 2000 then 'Gold'
            else 'Platinum'
        end as value_segment

    from joined

)

select * from segmented