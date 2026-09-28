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
    'enterprise_mds_elt_pipeline',
    default_args=default_args,
    description='Executes the hourly dual-domain dbt pipeline (FinTech & Q-Commerce)',
    schedule_interval='@hourly',
    start_date=datetime(2026, 9, 28),
    catchup=False,
    tags=['dbt', 'fintech', 'q-commerce', 'kimball'],
) as dag:

    # 1. Update SCD Type 2 Snapshots (FinTech Credit Limits & Darkstore Capacity)
    dbt_snapshot = BashOperator(
        task_id='dbt_snapshot',
        bash_command='dbt snapshot --profiles-dir .',
        cwd='/opt/airflow/dbt_project'
    )

    # 2. Run Staging & Mart Models across both domains
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='dbt run --profiles-dir .',
        cwd='/opt/airflow/dbt_project'
    )

    # 3. Validate Data Contracts & Anomaly Checks
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='dbt test --profiles-dir .',
        cwd='/opt/airflow/dbt_project'
    )

    dbt_snapshot >> dbt_run >> dbt_test
