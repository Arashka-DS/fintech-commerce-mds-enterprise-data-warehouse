from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'data_engineering',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'enterprise_mds_dual_domain_pipeline', # Updated ID
    default_args=default_args,
    description='Executes the hourly dual-domain dbt pipeline (FinTech & Q-Commerce)',
    schedule_interval='@hourly',
    start_date=datetime(2026, 9, 28),
    catchup=False,
    tags=['dbt', 'fintech', 'q-commerce', 'kimball'],
) as dag:

    dbt_snapshot = BashOperator(
        task_id='dbt_snapshot',
        bash_command='dbt snapshot --profiles-dir .',
        cwd='/opt/airflow/dbt_project'
    )

    dbt_build = BashOperator(
        task_id='dbt_build',
        bash_command='dbt build --profiles-dir .',
        cwd='/opt/airflow/dbt_project'
    )

    dbt_snapshot >> dbt_build
