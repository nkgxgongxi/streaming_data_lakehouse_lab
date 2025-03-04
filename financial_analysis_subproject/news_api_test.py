from newsapi import NewsApiClient
import configparser
import os
import pandas as pd
from data_ingestion_utils import Snowflake_Ops
from retrieve_config import retrieve_config_info


# Read the API key
config = retrieve_config_info("config.ini")
my_api_key = config.get("api", "key")

# print(f"API Key: {my_api_key}")

# Init
newsapi = NewsApiClient(api_key=my_api_key)

# /v2/top-headlines
# top_headlines = newsapi.get_top_headlines(q='trump',
#                                           sources='bbc-news',
#                                           language='en')

def get_news_data(sources:list, start_date:str, end_date:str, topic:str):
    """
        This functions calls NesAPI to retrieve news details based on given search criteria. 

        keyword arguments:

            - sources: a list of string with the news sources user would like to search. In this project, user can get retrieve this reference data from a Snowflake table. 
            - start_date & end_date: strings format YYYY-MM-DD to define the search date range.
            - topic: a string to define the topic a user would like to search.

        Returns:

            If there is news suitable for searching criteria, data will be returned in python dict format; Otherwise, returning None value. 
        
    """
    # Validate News Source Info
    if len(sources) == 0:
        print("No source is provided... no data is retrieved.")
        return None
    
    if len(sources) == 1:
            source_str = sources[0]
    else:
        source_str = ','.join(sources)
    
    print(source_str)
    
    all_articles = newsapi.get_everything(q=topic,
                                            sources=source_str,
                                            from_param=start_date,
                                            to=end_date,
                                            language='en',
                                            sort_by='relevancy',
                                            page=1)
    
    # Handle the situation where there is no data found.
    number_of_news = all_articles['totalResults']
    print("{number_of_news} news found from provided sources with related topic.".format(number_of_news=number_of_news))
    if  number_of_news > 0:    
        news_data = all_articles['articles']
    else:
        return None
    
    # TODO: How to get data with pagination (second page or so).
    return news_data
    

# /v2/top-headlines/sources
# define a function to read all sources into a dataframe
def get_news_sources_data():
    sources = newsapi.get_sources()

    # returned value is a dict
    print(type(sources))

    source_data = sources['sources']
    df = pd.DataFrame(source_data)

    return df

def ingest_news_sources(snowflake_ops:Snowflake_Ops):
    source_df = get_news_sources_data()
    print("There are {0} sources from NewsAPI.".format(source_df.shape[0]))
    source_df = snowflake_ops.cleanup_source_data(source_df)
    snowflake_ops.load_data_to_snowflake(source_df, 
                           table_name="NEWS_SOURCES", 
                           mode="overwrite"
                           )
    
def ingest_news_data(snowflake_ops:Snowflake_Ops):
    news_data = get_news_data(sources=['bloomberg', 'the-wall-street-journal', 'techcrunch', 'fortune', 'the-next-web', 'cnn', 'abc-news', 'google-news'], topic='AI', start_date='2025-02-25', end_date='2025-03-03')
    if news_data != None: 
        print(len(news_data))
        news_df = pd.DataFrame(news_data)
        print(news_df.columns)
        news_df[['source_id', 'source_name']] = pd.json_normalize(news_df['source'].values.tolist())
        news_df['topic'] = 'AI'
        news_df = news_df[['title', 'content', 'author', 'url', 'source_id', 'topic', 'publishedAt']]

        news_df = snowflake_ops.cleanup_source_data(news_df)
        snowflake_ops.load_data_to_snowflake(news_df, 
                           table_name="NEWS", 
                           mode="overwrite"
                           )



if __name__ == '__main__':
    # print(get_news_data.__doc__)
    testSnowOps = Snowflake_Ops()
    testSnowOps.establish_snowflake_connection(target_database='RAW', target_schema='FINANCIAL_INFO')
    # ingest_news_sources(testSnowOps)
    ingest_news_data(testSnowOps)
    testSnowOps.close_snowflake_connection()



