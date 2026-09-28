# Enterprise Modern Data Stack (MDS) Warehouse

A production-grade batch ELT pipeline demonstrating Kimball dimensional modeling, automated historical record preservation (SCD Type 2), and data contracts.

## 🏛️ Dual-Domain Dimensional Modeling
This warehouse is engineered to support multiple high-throughput business units simultaneously:
1. **FinTech Settlement Mart (`fct_transactions`):** Models interbank clearing pipelines, applying Slowly Changing Dimensions (SCD Type 2) to customer credit limits to preserve historical risk analysis integrity.
2. **Q-Commerce Fulfillment Mart (`fct_fulfillment_latency`):** Models the strict operational economics of the 30-minute delivery promise. Breaks down order lifecycle events into `pick_latency_seconds`, `rider_wait_seconds`, and tracks real-time `is_sla_breached` flags across dark stores.

## ⚙️ Core Engineering Capabilities
- **Quarantine Pattern & Data Sanitization:** Invalid OLTP records (e.g., negative order amounts, chronologically reversed timestamps) are diverted to a dead-letter quarantine table for audit.
- **Incremental Processing:** Fact models utilize 3-day dynamic lookback windows to securely ingest late-arriving batch facts without full-table recomputation.
- **Elementary Data Observability:** Implements statistical anomaly monitors ($\pm 3\sigma$ volume shifts) over daily fulfillment counts.
- **CI/CD & Orchestration:** `GitHub Actions` validates dbt singular contracts on PR. `Apache Airflow` orchestrates hourly DAG synchronizations.

## 🚀 Quick Start
```bash
docker-compose up -d --build
cd dbt_project
dbt deps && dbt snapshot && dbt run && dbt test
