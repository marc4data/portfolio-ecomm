with 

source as (

    select * from {{ source('thelook', 'orders') }}

),

renamed as (

    select
        order_id,
        user_id,
        status as order_status,
        gender,
        created_at,
        returned_at,
        shipped_at,
        delivered_at,
        num_of_item as line_item_cnt

    from source

)

select * from renamed