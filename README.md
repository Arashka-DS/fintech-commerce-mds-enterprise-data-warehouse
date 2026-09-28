# Enterprise Modern Data Stack (MDS) Warehouse

A production-grade batch ELT pipeline demonstrating Kimball dimensional modeling, automated historical record preservation (SCD Type 2), and data contracts.

## 🏛️ Dual-Domain Dimensional Modeling
This warehouse is engineered to support multiple high-throughput business units simultaneously:
1. **FinTech Settlement Mart (`fct_transactions`):** Models interbank clearing pipelines, applying Slowly Changing Dimensions (SCD Type 2) to customer credit limits to preserve historical risk analysis integrity.
2. **Q-Commerce Fulfillment Mart (`fct_fulfillment_latency`):** Models the strict operational economics of the 30-minute delivery promise. Breaks down order lifecycle events into `pick_latency_seconds`, `rider_wait_seconds`, and tracks real-time `is_sla_breached` flags across dark stores.

## ⚙️ Core Engineering Capabilities
- **Quarantine Pattern & Data Sanitization:** Invalid OLTP records (e.g., negative order amounts, chronologically reversed timestamps) are diverted to a dead-letter quarantine table for audit.
- **Incremental Processing:** Fact models utilize 3-day dynamic lookback windows to securely ingest late-arriving batch facts without full-table recomputation.
- **Data Observability:** Implements data contracts (e.g., positive order bounds, lifecycle validation) to halt the pipeline if upstream schemas shift unexpectedly.
- **Orchestration:** `Apache Airflow` orchestrates hourly DAG synchronizations, executing `dbt snapshot`, `dbt run`, and `dbt test` in sequence.

## 🚀 Quick Start
1. **Boot the Infrastructure (Airflow, Postgres, Metabase):**
   ```bash
   docker-compose up -d --build
   ```
   
2. **Access the Interfaces:**

**Apache Airflow UI:** Navigate to `http://localhost:8080` (admin/admin). Toggle the `enterprise_mds_elt_pipeline` DAG to execute the ELT run.

**Metabase BI:** Navigate to `http://localhost:3000` to visualize the resulting Kimball Star Schemas.

