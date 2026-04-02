with order_items as (

    select * from {{ ref('int_orders_joined') }}

),

products as (

    select * from {{ ref('int_product_inventory') }}

),

final as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.user_id,
        order_items.product_id,
        order_items.inventory_item_id,
        order_items.order_item_status,
        order_items.sale_price,
        order_items.created_at,
        order_items.returned_at,
        order_items.shipped_at,
        order_items.delivered_at,

        products.retail_price,
        products.cost,

        -- derived metrics
        round(order_items.sale_price - products.cost, 2)                as gross_profit,
        round(
            safe_divide(
                order_items.sale_price - products.cost,
                order_items.sale_price
            ) * 100, 2
        )                                                                as gross_margin_pct

    from order_items
    left join products using (product_id)

)

select * from final