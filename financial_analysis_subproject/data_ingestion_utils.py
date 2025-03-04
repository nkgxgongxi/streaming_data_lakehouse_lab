import pandas as pd
import datetime as dt
from snowflake.connector import connect
from snowflake.connector.pandas_tools import write_pandas

from retrieve_config import retrieve_config_info


class Snowflake_Ops():

    def __init__(self):
        # Initialise a Snowflake connection using configuration information
        self.config = None
        self.conn = None
        # self.conn = self.establish_snowflake_connection(self.set_snowflake_config())


    def get_snowflake_config(self):
        return self.config
    
    def set_snowflake_config(self):
        config_val = retrieve_config_info("config.ini")
        self.config = config_val['snowflake']
    

    def establish_snowflake_connection(self, target_database:str = None, target_schema:str = None):
        self.set_snowflake_config()
        self.conn = connect(
            user=self.config['user'],
            password=self.config['password'],
            account=self.config['account'],
            warehouse=self.config['warehouse'],  
            database=target_database if target_database != None else self.config['database'],
            schema=target_schema if target_schema != None else self.config['schema'],
            role=self.config['role']
        )

    def cleanup_source_data(self, df:pd.DataFrame):
        df['loaded_by'] = 'system_user'  # Replace with the actual username or system name
        df['last_updated_at'] = dt.datetime.now()
        df.columns = [c.upper() for c in df.columns]

        return df



    def load_data_to_snowflake(self, df:pd.DataFrame, table_name:str, mode:str):
        # Establish a connection to Snowflake
        conn = self.conn
        # Create a cursor object
        cursor = conn.cursor()

        try:
            cursor.execute(f"SELECT * FROM {table_name} LIMIT 1")
            table_exists = True
        except Exception as e:
            if "does not exist" in str(e):
                table_exists = False
            else:
                raise e

        if not table_exists:
            # Extract column names and data types dynamically from the DataFrame
            df_columns = df.columns.tolist()  # Get column names
            dtypes = df.dtypes  # Get data types
            # TODO: It seems like most of the data types are object, so they are mapped into String. How can I make this mapping smarter?
            # print(dtypes)
            # Map Pandas data types to Snowflake data types
            type_mapping = {
                "object": "STRING",
                "int64": "INT",
                "float64": "FLOAT",
                "bool": "BOOLEAN",
                "datetime64[us]": "TIMESTAMP"
            }

            # Generate the CREATE TABLE query dynamically
            table_columns_with_type = []
            for col in df_columns:
                snowflake_type = type_mapping.get(str(dtypes[col]), "STRING")  # Default to STRING if type is not mapped
                table_columns_with_type.append(f"{col.upper()} {snowflake_type}")

            # print(table_columns_with_type)

            create_table_query = """CREATE TABLE IF NOT EXISTS {table_name} ({table_columns});""".format(
                table_name=table_name, 
                table_columns=','.join(table_columns_with_type)
            )
        
            # print(create_table_query)
            cursor.execute(create_table_query)

        
        if mode == 'overwrite':
            delete_records_query = """TRUNCATE TABLE {0}""".format(table_name)
            cursor.execute(delete_records_query)
        
        df['LAST_UPDATED_AT'] = df['LAST_UPDATED_AT'].dt.strftime('%Y-%m-%dT%H:%M:%S')
        # Load the DataFrame into Snowflake
        success, nchunks, nrows, _ = write_pandas(
            conn=conn,
            df=df,
            table_name=table_name
        )

        if success:
            print(f"Data loaded successfully: {nrows} rows inserted into {table_name}.")
        else:
            print("Failed to load data.")

    
    def close_snowflake_connection(self):
        self.conn.close()