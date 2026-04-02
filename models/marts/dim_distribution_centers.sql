with distribution_centers as (

    select * from {{ ref('stg_thelook__distribution_centers') }}

),

final as (

    select
        dc_id,
        dc_name,
        latitude,
        longitude,
        dc_geom

    from distribution_centers

)

select * from final