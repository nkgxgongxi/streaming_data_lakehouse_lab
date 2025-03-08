from airflow import DAG
from utils.news_api_test import ingest_news_sources
from utils.data_ingestion_utils import Snowflake_Ops
from airflow.operators.python_operator import PythonOperator
from datetime import datetime

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
        op_kwargs={'snowflake_ops':Snowflake_Ops(config_location='/opt/airflow_home/')}
    )

    ingest_news_sources_task
