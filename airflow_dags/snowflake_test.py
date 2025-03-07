from airflow import DAG
from airflow.providers.snowflake.operators.snowflake import SnowflakeSqlApiOperator
from datetime import datetime

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 3, 7),
    'retries': 1,
}

with DAG(
    'snowflake_operator_dag',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
) as dag:

    run_query = SnowflakeSqlApiOperator(
        task_id='run_query',
        sql='SELECT COUNT(*) FROM NEWS',
        snowflake_conn_id='snowflake-test-conn',
    )

    run_query
