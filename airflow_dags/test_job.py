from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime, timedelta

# Define default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Instantiate the DAG
dag = DAG(
    'hello_world_dag',  # DAG ID
    default_args=default_args,
    description='A simple DAG to print Hello, World!',
    schedule_interval=timedelta(days=1),  # Run daily
    catchup=False,  # Disable catchup to avoid backfilling
)

# Define the task using BashOperator
print_hello_world = BashOperator(
    task_id='print_hello_world',  # Task ID
    bash_command='echo "Hello, World!"',  # Bash command to execute
    dag=dag,  # Assign the task to the DAG
)

# Set the task as the only task in the DAG
print_hello_world
