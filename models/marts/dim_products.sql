with products as (

    select * from {{ ref('int_product_inventory') }}

),

final as (

    select
        product_id,
        product_name,
        category,
        brand,
        department,
        retail_price,
        cost,
        avg_cost,
        total_inventory_items,
        units_sold,
        units_available,
        sell_through_rate,
        first_stocked_at,

        -- derived segments
        case
            when sell_through_rate >= 80    then 'high_velocity'
            when sell_through_rate >= 50    then 'mid_velocity'
            when sell_through_rate >= 20    then 'low_velocity'
            else 'slow_mover'
        end                             as inventory_segment,

        round(retail_price - avg_cost, 2)   as unit_margin,
        round(
            safe_divide(retail_price - avg_cost, retail_price) * 100, 2
        )                               as margin_pct

    from products

)

select * from final