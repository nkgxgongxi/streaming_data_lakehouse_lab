from newsapi import NewsApiClient
import configparser
import os
import pandas as pd
from data_ingestion_utils import load_data_to_snowflake, get_snowflake_target_table_column_info
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

# /v2/everything
def get_news_data(sources:list, start_date:str, end_date:str, topic:str):
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
                                            from_param='2025-02-11',
                                            to='2025-03-01',
                                            language='en',
                                            sort_by='relevancy',
                                            page=1)
    
    print(all_articles)
    return None
    

# /v2/top-headlines/sources
# define a function to read all sources into a dataframe
def get_news_sources_data():
    sources = newsapi.get_sources()

    # returned value is a dict
    print(type(sources))

    source_data = sources['sources']
    df = pd.DataFrame(source_data)

    return df



if __name__ == '__main__':
    # source_df = get_news_sources_data()
    # print("There are {0} sources from NewsAPI.".format(source_df.shape[0]))
    # df_columns, table_columns = get_snowflake_target_table_column_info(source_df)
    # print(table_columns)
    # load_data_to_snowflake(source_df, 
    #                        table_name="NEWS_SOURCES", 
    #                        mode="overwrite", 
    #                        df_columns=df_columns,
    #                        created_table_columns=table_columns
    #                        )

    get_news_data(sources=['bloomberg'], topic='trump', start_date='', end_date='')



