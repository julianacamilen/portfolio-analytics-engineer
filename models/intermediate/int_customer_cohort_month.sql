-- One row per customer, with their acquisition cohort (the month they signed up).

with customers as (

    select * from {{ ref('stg_customers') }}

)

select
    customer_id,
    {{ date_trunc_month('signup_date') }} as cohort_month

from customers