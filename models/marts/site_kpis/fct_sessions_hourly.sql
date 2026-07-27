-- Grain: 1 row per (day of week, hour of day).
-- Equivalent to "Average Sessions Per Hour" and "Quietest Traffic Windows"
-- from the original dashboard.
--
-- Uses the day_of_week() macro (macros/cross_db/) instead of a raw
-- EXTRACT(DOW ...) call, since day-of-week syntax and numbering differ
-- between DuckDB and BigQuery.

with sessions as (

    select * from {{ ref('stg_sessions') }}

),

by_day_hour as (

    select
        session_date,
        {{ day_of_week('session_date') }}  as day_of_week,      -- 0=Sunday .. 6=Saturday
        session_hour,
        count(*)                           as session_count

    from sessions
    group by 1, 2, 3

),

averaged as (

    select
        day_of_week,
        case day_of_week
            when 0 then 'Sunday'
            when 1 then 'Monday'
            when 2 then 'Tuesday'
            when 3 then 'Wednesday'
            when 4 then 'Thursday'
            when 5 then 'Friday'
            when 6 then 'Saturday'
        end                                as day_name,
        session_hour,
        round(avg(session_count), 2)       as avg_sessions,
        count(distinct session_date)       as days_observed

    from by_day_hour
    group by 1, 2, 3

)

select * from averaged
order by avg_sessions asc