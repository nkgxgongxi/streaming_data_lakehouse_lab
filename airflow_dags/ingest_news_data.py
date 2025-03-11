from airflow.decorators  import dag, task
from datetime import datetime, timedelta
from utils.data_ingestion_utils import Snowflake_Ops
from airflow_dags.utils.news_api_consumption import ingest_news_data

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2025, 3, 11),
    "retries": 1,
}

@dag(
        schedule="@daily", 
        default_args=default_args, 
        catchup=False,
        tags=["example"],
 )
def ingest_news_dag():
    @task
    def ingest_news_task():
        print("First, initialising a Snowflake Object.")
        test_snowflake_ops = Snowflake_Ops()
        test_snowflake_ops.config_location = '/opt/airflow_home'
        test_snowflake_ops.establish_snowflake_connection(target_database='RAW', target_schema='FINANCIAL_INFO')
        end_date = datetime.today().strftime("%Y-%m-%d")
        start_date = (datetime.today() - timedelta(1)).strftime("%Y-%m-%d")
        sources = ['bloomberg', 'the-wall-street-journal', 'techcrunch', 'fortune', 'the-next-web', 'cnn', 'google-news']
        for topic in ['AI', 'US Economy', 'Trump', 'China', 'World']:
            print("Now processing topic: {0}".format(topic))
            
            ingest_news_data(snowflake_ops=test_snowflake_ops, sources=sources, topic=topic, start_date=start_date, end_date=end_date)

    ingest_news_task()

ingest_news_dag()
