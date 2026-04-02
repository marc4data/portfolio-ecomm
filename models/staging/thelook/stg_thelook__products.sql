with 

source as (

    select * from {{ source('thelook', 'products') }}

),

renamed as (

    select
        id as product_id,
        cost,
        category,
        name,
        brand,
        retail_price,
        department,
        sku,
        distribution_center_id as dc_id

    from source

)

select * from renamed