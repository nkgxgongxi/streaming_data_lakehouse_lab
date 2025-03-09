from airflow import DAG
from utils.news_api_test import ingest_news_sources
from utils.data_ingestion_utils import Snowflake_Ops
from airflow.operators.python_operator import PythonOperator
from datetime import datetime

test_snowflake_ops = Snowflake_Ops()
test_snowflake_ops.config_location = '/opt/airflow_home'
test_snowflake_ops.establish_snowflake_connection(target_database='RAW', target_schema='FINANCIAL_INFO')

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 7),
    'retries': 1,
}

with DAG(
    dag_id = 'snowflake_operator_dag',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
) as dag:

    ingest_news_sources_task = PythonOperator(
        task_id='Ingest_News_Source',
        python_callable = ingest_news_sources,
        op_kwargs={'snowflake_ops':test_snowflake_ops}
    )

    ingest_news_sources_task
