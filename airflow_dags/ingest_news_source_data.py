from airflow.decorators  import dag, task
from datetime import datetime
from utils.data_ingestion_utils import Snowflake_Ops
from airflow_dags.utils.news_api_consumption import ingest_news_sources

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2025, 3, 10),
    "retries": 1,
}

@dag(
        schedule="@weekly", 
        default_args=default_args, 
        catchup=False,
        tags=["example"],
 )
def ingest_news_sources_dag():
    @task
    def ingest_news_sources_task():
        print("First, initialising a Snowflake Object.")
        test_snowflake_ops = Snowflake_Ops()
        test_snowflake_ops.config_location = '/opt/airflow_home'
        test_snowflake_ops.establish_snowflake_connection(target_database='RAW', target_schema='FINANCIAL_INFO')
        ingest_news_sources(snowflake_ops=test_snowflake_ops)

    ingest_news_sources_task()

ingest_news_sources_dag()
