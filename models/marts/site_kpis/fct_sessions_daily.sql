-- Grain: 1 row per day.
-- Equivalent to the "Average session duration", "Session count",
-- "% of sessions under 5 minutes" and "Bounce rate" cards from the
-- original dashboard, rebuilt with a generic domain/naming.
--
-- Note: conditional aggregates are written as CASE WHEN inside the
-- aggregate function (e.g. avg(case when ... )) instead of the
-- FILTER (WHERE ...) syntax. FILTER is supported by DuckDB/Postgres but
-- not by BigQuery Standard SQL -- CASE WHEN works identically on both,
-- which keeps this project portable across warehouses.

with sessions as (

    select * from {{ ref('stg_sessions') }}

),

daily as (

    select
        session_date,

        count(*)                                            as session_count,
        round(avg(duration_minutes), 2)                      as avg_session_minutes,

        round(
            avg(case when duration_minutes >= 5 then duration_minutes end), 2
        )                                                    as avg_session_minutes_5min_plus,

        round(
            100.0 * count(case when duration_minutes < 5 then 1 end) / count(*), 2
        )                                                    as pct_sessions_under_5min,

        round(
            100.0 * sum(case when is_bounce then 1 else 0 end) / count(*), 2
        )                                                    as bounce_rate_pct,

        round(
            100.0 * sum(case when end_reason = 'no_activity' then 1 else 0 end) / count(*), 2
        )                                                    as pct_end_no_activity,

        round(
            100.0 * sum(case when end_reason = 'timeout' then 1 else 0 end) / count(*), 2
        )                                                    as pct_end_timeout,

        round(
            100.0 * sum(case when end_reason = 'logout' then 1 else 0 end) / count(*), 2
        )                                                    as pct_end_logout

    from sessions
    group by 1

)

select * from daily
order by session_date