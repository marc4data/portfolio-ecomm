with funnel as (

    select * from {{ ref('int_funnel_events') }}

),

session_summary as (

    select
        session_id,
        user_id,
        max(traffic_source)                                     as traffic_source,
        min(event_at)                                           as session_start_at,
        max(event_at)                                           as session_end_at,
        count(*)                                                as total_events,
        max(funnel_stage)                                       as max_funnel_stage,
        max(session_converted)                                  as converted,

        -- stage flags
        max(case when event_type = 'home'       then 1 else 0 end) as visited_home,
        max(case when event_type = 'department' then 1 else 0 end) as visited_department,
        max(case when event_type = 'product'    then 1 else 0 end) as visited_product,
        max(case when event_type = 'cart'       then 1 else 0 end) as added_to_cart,
        max(case when event_type = 'purchase'   then 1 else 0 end) as purchased,

        timestamp_diff(
            max(event_at), min(event_at), second
        )                                                       as session_duration_seconds

    from funnel
    group by session_id, user_id

)

select * from session_summary