import pandas as pd
import snowflake.connector

from retrieve_config import retrieve_config_info



# Read Snowflake configuration information
config = retrieve_config_info("config.ini")
snowflake_config = config['snowflake']


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