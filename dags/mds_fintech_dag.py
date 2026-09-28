from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data_platform_lead',
    'depends_on_past': False,
    'start_date': datetime(2026, 1, 1),
    'email_on_failure': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=3),
}

with DAG(
    'fintech_warehouse_batch_elt',
    default_args=default_args,
    description='Automated SCD2, Kimball transformations, data testing, and Elementary observability',
    schedule_interval='@hourly',
    catchup=False,
    max_active_runs=1
) as dag:

    # 1. Execute SCD Type 2 Snapshots
    dbt_snapshot = BashOperator(
        task_id='dbt_snapshot_customers',
        bash_command='cd /opt/airflow/dbt_project && dbt snapshot --profiles-dir .'
    )

    # 2. Run Staging and Dimensional Models
    dbt_run = BashOperator(
        task_id='dbt_run_marts',
        bash_command='cd /opt/airflow/dbt_project && dbt run --profiles-dir .'
    )

    # 3. Execute Generic, Singular, and Anomaly Tests
    dbt_test = BashOperator(
        task_id='dbt_test_contracts',
        bash_command='cd /opt/airflow/dbt_project && dbt test --profiles-dir .'
    )

    # 4. Generate Elementary Observability Dashboard
    elementary_report = BashOperator(
        task_id='elementary_generate_report',
        bash_command='cd /opt/airflow/dbt_project && edr monitor report --profiles-dir . --file-path /opt/airflow/dbt_project/elementary_report.html'
    )

    # Linear Dependency Pipeline
    dbt_snapshot >> dbt_run >> dbt_test >> elementary_report
