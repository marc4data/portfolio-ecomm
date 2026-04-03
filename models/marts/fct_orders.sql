with orders as (

    select * from {{ ref('int_orders') }}

),

final as (

    select
        orders.order_id,
        orders.user_id,
        orders.order_status,

        orders.line_item_cnt,
        orders.revenue_amt,
        orders.cost_amt,
        orders.margin_amt,

        orders.days_to_deliver,
        orders.days_to_ship,
        orders.returned_ind,
        orders.completed_ind,

        orders.created_at,
        orders.returned_at,
        orders.shipped_at,
        orders.delivered_at

    from orders

)

select * from final