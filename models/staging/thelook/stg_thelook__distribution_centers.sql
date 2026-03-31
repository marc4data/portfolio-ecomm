with 

source as (

    select * from {{ source('thelook', 'distribution_centers') }}

),

renamed as (

    select
        id as dc_id,
        name as dc_name,
        latitude,
        longitude,
        distribution_center_geom as dc_geom

    from source

)

select * from renamed