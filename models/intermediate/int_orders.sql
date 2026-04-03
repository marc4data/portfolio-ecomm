with orders as (

    select * from {{ ref('stg_thelook__orders') }}

),

order_items as (

    select * from {{ ref('stg_thelook__order_items') }}

),

inventory_items as (

    select * from {{ ref('stg_thelook__inventory_items') }}

),

order_items_summary as (

select 
    order_items.order_id,
    orders.user_id,
    orders.created_at,

    -- aggregate first
    sum(order_items.sale_price)                             as revenue_amt,
    sum(inventory_items.cost)                               as cost_amt,
    sum(order_items.sale_price - inventory_items.cost)      as margin_amt

from orders
left join order_items 
    on orders.order_id = order_items.order_id
left join inventory_items 
    on order_items.inventory_item_id = inventory_items.inventory_item_id
where orders.order_status != 'Cancelled'
group by
    order_items.order_id,
    orders.user_id,
    orders.created_at

),

running_totals as (

    select
        *,
        row_number() over (partition by user_id order by created_at asc)     as cx_order_seq,
        sum(revenue_amt) over (partition by user_id order by created_at asc)    as cx_running_revenue_amt,
        sum(cost_amt) over (partition by user_id order by created_at asc)       as cx_running_cost_amt,
        sum(margin_amt) over (partition by user_id order by created_at asc)     as cx_running_margin_amt

    from order_items_summary

),

final as (

    select
        -- keys
        orders.order_id,
        orders.user_id,

        -- dimensions
        orders.order_status,
        running_totals.cx_order_seq,
        
        --metrics
        orders.line_item_cnt,
        order_items_summary.revenue_amt,
        order_items_summary.cost_amt,
        order_items_summary.margin_amt,

        running_totals.cx_running_revenue_amt,
        running_totals.cx_running_cost_amt,
        running_totals.cx_running_margin_amt,

        -- derived metrics
        timestamp_diff(orders.delivered_at, orders.created_at, day)     as days_to_deliver,
        timestamp_diff(orders.shipped_at, orders.created_at, day)       as days_to_ship,

        case
            when orders.order_status = 'Returned' then 1
            when orders.order_status != 'Cancelled' then 0
            else null
        end                                                              as returned_ind,
        case
            when orders.order_status = 'Complete' then 1
            else 0 
        end                                                              as completed_ind,

        -- timestamps
        orders.created_at,
        orders.returned_at,
        orders.shipped_at,
        orders.delivered_at,

    from orders
    left join order_items_summary on orders.order_id = order_items_summary.order_id
    left join running_totals on orders.order_id = running_totals.order_id
)

select * from final