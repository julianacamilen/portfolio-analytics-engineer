-- Grain: 1 row per (cohort_month, months_since_cohort).
-- Classic cohort retention matrix: for each acquisition cohort (the month
-- a customer signed up), how many of them were still active N months
-- later, and what % of the original cohort that represents.

with cohorts as (

    select * from {{ ref('int_customer_cohort_month') }}

),

activity as (

    select * from {{ ref('int_customer_monthly_activity') }}

),

cohort_size as (

    select
        cohort_month,
        count(distinct customer_id) as cohort_size

    from cohorts
    group by 1

),

activity_with_cohort as (

    select
        cohorts.cohort_month,
        cohorts.customer_id,
        {{ months_between('cohorts.cohort_month', 'activity.activity_month') }} as months_since_cohort

    from cohorts
    inner join activity
        on cohorts.customer_id = activity.customer_id
    where activity.activity_month >= cohorts.cohort_month

),

retention as (

    select
        cohort_month,
        months_since_cohort,
        count(distinct customer_id) as active_customers

    from activity_with_cohort
    group by 1, 2

)

select
    retention.cohort_month,
    retention.months_since_cohort,
    retention.active_customers,
    cohort_size.cohort_size,
    round(100.0 * retention.active_customers / cohort_size.cohort_size, 2) as retention_pct

from retention
inner join cohort_size
    on retention.cohort_month = cohort_size.cohort_month

order by cohort_month, months_since_cohort