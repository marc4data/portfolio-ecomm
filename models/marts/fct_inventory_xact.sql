with inventory_items as (

    select * from {{ ref('stg_thelook__inventory_items') }}

),

products as (

    select * from {{ ref('dim_products') }}

),

joined as (

    select
        -- keys
        inventory_items.inventory_item_id                                          as inventory_item_id,
        inventory_items.product_id,
        inventory_items.dc_id,

        -- inventory financials
        inventory_items.cost,
        round(products.retail_price - inventory_items.cost, 2)    as potential_margin,
        round(
            safe_divide(
                products.retail_price - inventory_items.cost,
                products.retail_price
            ) * 100, 2
        )                                                          as potential_margin_pct,

        -- timestamps
        inventory_items.created_at                                 as stocked_at,
        inventory_items.sold_at,

        -- derived metrics
        case
            when inventory_items.sold_at is not null then 1
            else 0
        end                                                        as sold_ind,

        timestamp_diff(
            coalesce(inventory_items.sold_at, current_timestamp()),
            inventory_items.created_at,
            day
        )                                                          as days_in_inventory,

        case
            when inventory_items.sold_at is not null
            then timestamp_diff(
                inventory_items.sold_at,
                inventory_items.created_at,
                day
            )
            else null
        end                                                        as days_to_sell,

        -- inventory age buckets (for unsold items)
        case
            when inventory_items.sold_at is not null            then 'sold'
            when timestamp_diff(
                current_timestamp(),
                inventory_items.created_at, day) <= 30           then '0-30 days'
            when timestamp_diff(
                current_timestamp(),
                inventory_items.created_at, day) <= 60           then '31-60 days'
            when timestamp_diff(
                current_timestamp(),
                inventory_items.created_at, day) <= 90           then '61-90 days'
            else '90+ days'
        end                                                        as inventory_age_bucket

    from inventory_items
    left join products
        on inventory_items.product_id = products.product_id

)

select * from joined