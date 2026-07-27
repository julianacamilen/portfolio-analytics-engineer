-- Staging layer: renames/types columns, no business logic here.
-- Rule of this layer: 1 staging model per source table, always.

with source as (

    select * from {{ source('raw', 'customers') }}

),

renamed as (

    select
        customer_id,
        cast(signup_date as date)  as signup_date,
        acquisition_channel,
        country

    from source

)

select * from renamed