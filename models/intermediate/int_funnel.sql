with session_events as (

    select * from {{ ref('stg_thelook__events') }}

),

session_lifecycle as (

    select
        -- keys
        session_id,
        user_id,
        
        -- dimensions
        ip_address,
        city,
        state,
        postal_code,
        browser,
        traffic_source,

        -- session boundaries
        min(created_at)                                                         as session_start_at,
        max(created_at)                                                         as session_end_at,
        count(*)                                                                as total_events,

        -- funnel stage indicators
        max(case when event_type = 'home'           then 1 else 0 end)          as home_ind,
        max(case when event_type = 'department'     then 1 else 0 end)          as department_ind,
        max(case when event_type = 'product'        then 1 else 0 end)          as product_ind,
        max(case when event_type = 'cart'           then 1 else 0 end)          as cart_ind,
        max(case when event_type = 'purchase'       then 1 else 0 end)          as purchase_ind,
        max(case when event_type = 'cancel'         then 1 else 0 end)          as cancel_ind

    from session_events
    group by 
        -- keys
        session_id,
        user_id,
        
        -- dimensions
        ip_address,
        city,
        state,
        postal_code,
        browser,
        traffic_source    

),

final as (

    select
        session_id,
        user_id,

        -- dimensions
        ip_address,
        city,
        state,
        postal_code,
        browser,
        traffic_source,

        -- session metadata
        session_start_at,
        session_end_at,
        total_events,
        timestamp_diff(session_end_at, session_start_at, second)                as session_duration_seconds,

        -- funnel stage indicators
        home_ind,
        department_ind,
        product_ind,
        cart_ind,
        purchase_ind,
        cancel_ind,

        CAST(home_ind AS STRING) || CAST(department_ind AS STRING) || CAST(product_ind AS STRING) || CAST(cart_ind AS STRING) || CAST(purchase_ind AS STRING) || CAST(cancel_ind AS STRING) as funnel_stage_bits,

        -- furthest funnel stage reached
        case
            when purchase_ind   = 1 then 'purchase'
            when cancel_ind     = 1 then 'cancel'
            when cart_ind       = 1 then 'cart'
            when product_ind    = 1 then 'product'
            when department_ind = 1 then 'department'
            else 'home'
        end                                                                     as funnel_last_stage,

        -- dropout stage
        case
            when purchase_ind   = 1 then 'completed'
            when cancel_ind     = 1 then 'cancelled'
            when cart_ind       = 1 then 'dropped_at_cart'
            when product_ind    = 1 then 'dropped_at_product'
            when department_ind = 1 then 'dropped_at_department'
            else 'dropped_at_home'
        end                                                                     as funnel_dropout_stage

    from session_lifecycle

)

select * from final