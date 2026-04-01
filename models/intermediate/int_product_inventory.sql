with products as (

    select * from {{ ref('stg_thelook__products') }}

),

inventory_items as (

    select * from {{ ref('stg_thelook__inventory_items') }}

),

inventory_summary as (

    select
        product_id,
        count(inventory_item_id)                        as total_inventory_items,
        countif(sold_at is not null)                    as units_sold,
        countif(sold_at is null)                        as units_available,
        avg(cost)                                       as avg_cost,
        min(created_at)                                 as first_stocked_at

    from inventory_items
    group by product_id

),

joined as (

    select
        products.product_id,
        products.name                   as product_name,
        products.category,
        products.brand,
        products.department,
        products.retail_price,
        products.cost,

        inventory_summary.total_inventory_items,
        inventory_summary.units_sold,
        inventory_summary.units_available,
        inventory_summary.avg_cost,
        inventory_summary.first_stocked_at,

        round(
            safe_divide(inventory_summary.units_sold, inventory_summary.total_inventory_items) * 100,
            2
        )                               as sell_through_rate

    from products
    left join inventory_summary
        on products.product_id = inventory_summary.product_id

)


select * from joined