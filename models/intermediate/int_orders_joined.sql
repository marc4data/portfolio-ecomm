with orders as (

    select * from {{ ref('stg_thelook__orders') }}

),

order_items as (

    select * from {{ ref('stg_thelook__order_items') }}

),

joined as (

    select
        orders.order_id,
        orders.user_id,
        orders.order_status,
        orders.gender,
        orders.line_item_cnt,
        orders.created_at,
        orders.returned_at,
        orders.shipped_at,
        orders.delivered_at,

        order_items.order_item_id,
        order_items.product_id,
        order_items.inventory_item_id,
        order_items.sale_price,
        order_items.order_item_status

    from orders
    left join order_items
        on orders.order_id = order_items.order_id

)

select * from joined