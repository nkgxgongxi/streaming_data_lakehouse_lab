with external_news_sources as (
    
    select * from {{ source('news_api_temp_source', 'news_sources') }}
),

final as (

    select s.*, CURRENT_TIMESTAMP(2) as last_updated_at from external_news_sources s
)

select * from final