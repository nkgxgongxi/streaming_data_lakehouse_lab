from newsapi import NewsApiClient
import configparser
import os
import pandas as pd
import snowflake.connector

# Get the absolute path of the directory where the script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Construct the full path to config.ini
config_path = os.path.join(script_dir, "config.ini")

# Load the configuration file
config = configparser.ConfigParser()
config.read(config_path)

# Read the API key
my_api_key = config.get("api", "key")
snowflake_config = config['snowflake']

# print(f"API Key: {my_api_key}")

# Init
newsapi = NewsApiClient(api_key=my_api_key)

# /v2/top-headlines
# top_headlines = newsapi.get_top_headlines(q='trump',
#                                           sources='bbc-news',
#                                           language='en')

# /v2/everything
# all_articles = newsapi.get_everything(q='bitcoin',
#                                       sources='bbc-news,the-verge',
#                                       domains='bbc.co.uk,techcrunch.com',
#                                       from_param='2017-12-01',
#                                       to='2017-12-12',
#                                       language='en',
#                                       sort_by='relevancy',
#                                       page=2)

# /v2/top-headlines/sources
# define a function to read all sources into a dataframe
def get_sources():
    sources = newsapi.get_sources()

    # returned value is a dict
    print(type(sources))

    source_data = sources['sources']
    df = pd.DataFrame(source_data)

    return df

def get_snowflake_target_table_column_info(df:pd.DataFrame):
    # Extract column names and data types dynamically from the DataFrame
    df_columns = df.columns.tolist()  # Get column names
    dtypes = df.dtypes  # Get data types

    # Map Pandas data types to Snowflake data types
    type_mapping = {
        "object": "STRING",
        "int64": "INT",
        "float64": "FLOAT",
        "bool": "BOOLEAN",
        "datetime64[ns]": "TIMESTAMP"
    }

    # Generate the CREATE TABLE query dynamically
    created_table_columns = []
    for col in df_columns:
        snowflake_type = type_mapping.get(str(dtypes[col]), "VARCHAR(10000)")  # Default to STRING if type is not mapped
        created_table_columns.append(f"{col} {snowflake_type}")

    return df_columns, created_table_columns


def load_data_to_snowflake(df:pd.DataFrame, table_name:str, mode:str, df_columns: list, created_table_columns:list):
    # Establish a connection to Snowflake
    conn = snowflake.connector.connect(
        user=snowflake_config['user'],
        password=snowflake_config['password'],
        account=snowflake_config['account'],
        warehouse=snowflake_config['warehouse'],
        database=snowflake_config['database'],
        schema=snowflake_config['schema'],
        role=snowflake_config['role']
    )

    # Create a cursor object
    cursor = conn.cursor()

    # Define the target table name
    table_name = "news_sources"

    # Create the table in Snowflake (if it doesn't exist)
    create_table_query = """CREATE TABLE IF NOT EXISTS {table_name} ({table_columns});""".format(table_name=table_name, table_columns=', '.join(created_table_columns))
    print(create_table_query)
    cursor.execute(create_table_query)

    delete_records_query = """TRUNCATE TABLE {0}""".format(table_name)
    if mode == 'overwrite':
        cursor.execute(delete_records_query)
    
    # Insert data from the DataFrame into the Snowflake table
    for _, row in df.iterrows():
        insert_query = f"""
        INSERT INTO {table_name} ({', '.join(df_columns)})
        VALUES ({', '.join(['%s'] * len(df_columns))});
        """
        cursor.execute(insert_query, tuple(row))
        
    # Commit the transaction
    conn.commit()

    # Close the connection
    cursor.close()
    conn.close()

    print("Data successfully loaded into Snowflake!")


if __name__ == '__main__':
    source_df = get_sources()
    print("There are {0} sources from NewsAPI.".format(source_df.shape[0]))
    df_columns, table_columns=get_snowflake_target_table_column_info(source_df)
    print(table_columns)
    load_data_to_snowflake(source_df, 
                           table_name="NEWS_SOURCES", 
                           mode="overwrite", 
                           df_columns=df_columns,
                           created_table_columns=table_columns
                           )



