with orders as (

    select * from {{ ref('stg_thelook__orders') }}

),

users as (

    select * from {{ ref('stg_thelook__users') }}

),

order_summary as (

    select
        user_id,
        count(order_id)                             as lifetime_order_cnt,
        sum(line_item_cnt)                          as lifetime_item_cnt,
        min(created_at)                             as first_order_at,
        max(created_at)                             as most_recent_order_at,
        countif(order_status = 'returned')          as total_return_cnt,
        countif(order_status = 'complete')          as total_complete_cnt

    from orders
    group by user_id

),

joined as (

    select
        users.user_id,
        users.first_name,
        users.last_name,
        users.email,
        users.age,
        users.gender,
        users.country,
        users.city,
        users.traffic_source,
        users.created_at                as user_created_at,

        ifnull(order_summary.lifetime_order_cnt, 0) as lifetime_order_cnt,
        ifnull(order_summary.lifetime_item_cnt, 0) as lifetime_item_cnt,
        order_summary.first_order_at,
        order_summary.most_recent_order_at,
        ifnull(order_summary.total_return_cnt, 0) as total_return_cnt,
        ifnull(order_summary.total_complete_cnt, 0) as total_complete_cnt

    from users
    left join order_summary
        on users.user_id = order_summary.user_id

)

select * from joined