with users as (

    select * from {{ ref('int_user_orders') }}

),

final as (

    select
        user_id,
        first_name,
        last_name,
        email,
        age,
        gender,
        country,
        city,
        traffic_source,
        user_created_at,

        lifetime_order_cnt,
        lifetime_item_cnt,
        first_order_at,
        most_recent_order_at,
        total_return_cnt,
        total_complete_cnt,

        -- derived segments
        case
            when lifetime_order_cnt = 0    then 'never_purchased'
            when lifetime_order_cnt = 1    then 'one_time'
            when lifetime_order_cnt <= 3   then 'repeat'
            else 'loyal'
        end                             as customer_segment,

        case
            when total_return_cnt = 0                              then 'no_returns'
            when safe_divide(total_return_cnt, lifetime_order_cnt)
                > 0.5                                           then 'high_returner'
            else 'low_returner'
        end                             as return_segment,

        timestamp_diff(
            most_recent_order_at, first_order_at, day
        )                               as customer_lifespan_days

    from users

)

select * from final