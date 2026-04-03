with orders as (

    select * from {{ ref('int_orders') }}

),

final as (

    select
        orders.order_id,
        orders.user_id,
        orders.order_status,
        orders.cx_order_seq,
        case
            when orders.cx_order_seq > 1 then 'Repeat'
            when orders.cx_order_seq = 0 then 'First' 
            else 'n/a'
        end as cx_order_type,
        orders.line_item_cnt,
        
        --metrics
        orders.revenue_amt,
        orders.cost_amt,
        orders.margin_amt,
        
        orders.cx_running_revenue_amt,
        orders.cx_running_cost_amt,
        orders.cx_running_margin_amt,

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