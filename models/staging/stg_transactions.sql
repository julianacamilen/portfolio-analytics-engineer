with source as (

    select * from {{ source('raw', 'transactions') }}

),

renamed as (

    select
        transaction_id,
        customer_id,
        transaction_type,
        status,
        amount,
        cast(created_at as timestamp) as created_at,
        cast(created_at as date)      as created_date

    from source

)

select * from renamed
