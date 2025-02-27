with external_news_sources as (
    
    select * from {{ source('news_api_temp_source', 'news_sources') }}
),

final as (

    select * from external_news_sources
)

select * from final