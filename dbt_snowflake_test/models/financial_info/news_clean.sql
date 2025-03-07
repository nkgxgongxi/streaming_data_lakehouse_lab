with news_raw as (
    
    select * from {{ source('news_data_raw', 'news') }}
),

final as (

    select title, 
           content,
           author,
           url,
           source_id,
           topic, 
           case when publishedat like '%T%Z' then publishedat else TO_VARCHAR(publishedat::Timestamp_TZ, 'yyyy-mm-ddThh:mi:ssZ') end as publishedat,
           loaded_by,
           last_updated_at 
    from news_raw
)

select * from final