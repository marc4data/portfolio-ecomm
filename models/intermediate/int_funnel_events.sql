with events as (

    select * from {{ ref('stg_thelook__events') }}

),

funnel as (

    select
        session_id,
        user_id,
        traffic_source,
        created_at                                              as event_at,
        event_type,

        -- funnel stage flags
        case event_type
            when 'home'         then 1
            when 'department'   then 2
            when 'product'      then 3
            when 'cart'         then 4
            when 'purchase'     then 5
            else 0
        end                                                     as funnel_stage,

        max(case when event_type = 'purchase' then 1 else 0 end)
            over (partition by session_id)                      as session_converted

    from events

)

select * from funnel
