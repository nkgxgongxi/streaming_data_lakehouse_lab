/* 
    First experiment with creating an incremental process to load data from Raw into a Stage phase (with duplication removal). 
    Somehow the compiler doesn't like config block to start with multiple lines, so format it as single line syntax.
 */
{{config(materialized='incremental', unique_key= ['url', 'title'], incremental_strategy='merge')}}

with news_raw as (
    
    select * from {{ source('news_data_raw', 'news') }}
    where last_updated_at >= dateadd(day, -10, current_date)

),
unique_news_raw as (
    
    select distinct title, 
           content,
           author,
           url,
           source_id,
           listagg(distinct topic, ',') over  (partition by (title,url)) as topic,
           case when publishedat like '%T%Z' then publishedat else to_varchar(publishedat::Timestamp_TZ, 'yyyy-mm-ddThh:mi:ssZ') end as publishedat,
           loaded_by,
           max(last_updated_at) over (partition by (title, url)) as last_updated_at
    from news_raw  -- Reference the source table
    where author is not null and author != ''

),
final as (
    
    select distinct title, 
        content, 
        author,
        url,
        source_id,
        topic,
        publishedat,
        loaded_by, 
        last_updated_at
    from unique_news_raw
    where
    -- notes: The else block is necessary because if the table doesn't exist, only having "if block" will result in an incomplete query after compilation.
    {% if is_incremental() -%}
        last_updated_at > nvl((select max(last_updated_at) from {{ this }}), dateadd(day, -10, current_date))
    {%- else -%}
        1 = 1
    {%- endif %}
    
)
select * from final