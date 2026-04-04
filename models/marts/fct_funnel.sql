with int_funnel as (

    select * from {{ ref('int_funnel') }}

),

users as (

    select
        user_id,
        customer_segment,
        return_segment,
        traffic_source      as user_traffic_source,
        country,
        age,
        gender

    from {{ ref('dim_users') }}

),

final as (

    select
        -- keys
        int_funnel.session_id,
        int_funnel.user_id,

        -- user context
        users.customer_segment,
        users.return_segment,
        users.country,
        users.age,
        users.gender,

        -- session dimensions
        int_funnel.ip_address,
        int_funnel.city,
        int_funnel.state,
        int_funnel.postal_code,
        int_funnel.browser,
        int_funnel.traffic_source,

        -- session metadata
        int_funnel.session_start_at,
        int_funnel.session_end_at,
        int_funnel.total_events,
        int_funnel.session_duration_seconds,

        -- time dimensions
        extract(hour from int_funnel.session_start_at)                          as session_hour,
        extract(dayofweek from int_funnel.session_start_at)                     as session_day_of_week,
        extract(month from int_funnel.session_start_at)                         as session_month,
        format_timestamp('%A', int_funnel.session_start_at)                     as session_day_name,

        -- session duration buckets
        case
            when int_funnel.session_duration_seconds < 60       then 'under_1_min'
            when int_funnel.session_duration_seconds < 300      then '1_to_5_min'
            when int_funnel.session_duration_seconds < 600      then '5_to_10_min'
            when int_funnel.session_duration_seconds < 1800     then '10_to_30_min'
            else 'over_30_min'
        end                                                                     as session_duration_bucket,

        -- funnel stage indicators
        int_funnel.home_ind,
        int_funnel.department_ind,
        int_funnel.product_ind,
        int_funnel.cart_ind,
        int_funnel.purchase_ind,
        int_funnel.cancel_ind,

        -- funnel path fingerprint
        int_funnel.funnel_stage_bits,

        -- funnel depth score (0-5, sum of stage indicators excluding home)
        (
            int_funnel.department_ind +
            int_funnel.product_ind +
            int_funnel.cart_ind +
            int_funnel.purchase_ind +
            int_funnel.cancel_ind
        )                                                                       as funnel_depth_score,

        -- funnel summary
        int_funnel.funnel_last_stage,
        int_funnel.funnel_dropout_stage,

        -- conversion and engagement indicators
        int_funnel.purchase_ind                                                 as converted_ind,

        case
            when int_funnel.cart_ind = 1
            and int_funnel.purchase_ind = 0                                     then 1
            else 0
        end                                                                     as cart_abandon_ind,

        case
            when int_funnel.product_ind = 1
            and int_funnel.cart_ind = 0                                         then 1
            else 0
        end                                                                     as product_browse_no_cart_ind,

        case
            when int_funnel.total_events = 1
            and int_funnel.home_ind = 1                                         then 1
            else 0
        end                                                                     as bounce_ind

    from int_funnel
    left join users
        on int_funnel.user_id = users.user_id

)

select * from final