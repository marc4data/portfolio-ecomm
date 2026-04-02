with orders as (

    select * from {{ ref('int_orders_joined') }}

),

order_revenue as (

    select
        order_id,
        sum(sale_price) as order_revenue

    from orders
    group by order_id

),

final as (

    select
        orders.order_id,
        orders.user_id,
        orders.order_status,
        orders.line_item_cnt,
        orders.created_at,
        orders.returned_at,
        orders.shipped_at,
        orders.delivered_at,

        order_revenue.order_revenue,

        -- derived metrics
        timestamp_diff(orders.delivered_at, orders.created_at, day)     as days_to_deliver,
        timestamp_diff(orders.shipped_at, orders.created_at, day)       as days_to_ship,

        case
            when orders.order_status = 'returned' then true
            else false
        end                                                              as is_returned

    from orders
    left join order_revenue using (order_id)

)

select * from final