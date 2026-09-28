FROM apache/airflow:2.9.2-python3.11

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

USER airflow
# Install dbt for PostgreSQL
RUN pip install --no-cache-dir dbt-postgres==1.8.2
