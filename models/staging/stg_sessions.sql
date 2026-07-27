with source as (

    select * from {{ source('raw', 'sessions') }}

),

renamed as (

    select
        session_id,
        nullif(customer_id, '')        as customer_id,  -- empty string -> NULL (anonymous visitor)
        cast(started_at as timestamp)  as started_at,
        cast(started_at as date)       as session_date,
        cast(extract(hour from cast(started_at as timestamp)) as integer) as session_hour,
        duration_seconds,
        round(duration_seconds / 60.0, 2) as duration_minutes,
        end_reason,
        device_type,
        case when duration_seconds <= 30 then true else false end as is_bounce

    from source

)

select * from renamed