# Enterprise Modern Data Stack (MDS) Warehouse

A production-grade batch ELT pipeline demonstrating Kimball dimensional modeling, automated historical record preservation (SCD Type 2), data quarantine contracts, and cross-domain orchestration using `dbt-core`, `PostgreSQL`, and `Apache Airflow`.

## 🏛️ Dual-Domain Dimensional Modeling

This enterprise warehouse serves two operational domains within a unified Kimball Star Schema:

### 1. FinTech Clearinghouse Mart (`analytics.fct_transactions`)
* **Core Problem:** Captures high-throughput interbank clearing flows (Satna, Paya, POS) while preventing historical bias caused by user attribute mutations.
* **Architecture:** Ingests raw financial events into incremental fact tables. Implements **Slowly Changing Dimensions (SCD Type 2)** via `dbt snapshot` on customer credit limits, preserving point-in-time risk evaluations.
* **PII Protection:** Hashes national identifiers and masks telephone numbers into deterministic SHA-256 tokens using custom Jinja macros (`masking_macros.sql`).

### 2. Q-Commerce Darkstore Fulfillment Mart (`analytics.fct_fulfillment_latency`)
* **Core Problem:** Monitors the strict operational economics of the 15-to-30 minute grocery delivery model across distributed micro-fulfillment centers.
* **Architecture:** Tracks order lifecycle milestones across four distinct phases:
  $$\text{Total Fulfillment Time} = T_{\text{pick\_latency}} + T_{\text{rider\_wait}} + T_{\text{last\_mile}}$$
* **Root-Cause Attribution:** Classifies SLA violations ($>30\text{ min}$) into operational drivers: `PICKING_BOTTLENECK`, `RIDER_DISPATCH_DELAY`, or `LAST_MILE_TRAFFIC`.

## ⚙️ Data Engineering & Observability Features

* **Dead-Letter Quarantine Pattern:** Rejects corrupted OLTP records (negative payment amounts, reversed timestamps) and routes them to `staging.quarantine_invalid_orders` and `staging.quarantine_invalid_transactions` without halting downstream pipelines.
* **Incremental Processing:** Employs dynamic 3-day lookback windows on fact models to ingest late-arriving batch entries without full-table scans.
* **Singular Data Contracts:** Validates chronological progressions using custom schema assertions (`assert_valid_order_lifecycle.sql`).
* **Airflow Orchestrator:** Manages hourly ELT workflows, running `dbt snapshot`, `dbt run`, and `dbt test` sequentially.

## 🚀 Quick Start

1. **Boot the Infrastructure (Airflow, Postgres, Metabase):**
   ```bash
   docker-compose up -d --build
   ```

2. **Access the Web Interfaces:**
   * **Apache Airflow UI:** `http://localhost:8080` (Credentials: `admin` / `admin`). Unpause and trigger `enterprise_mds_elt_pipeline`.
   * **Metabase Analytics:** `http://localhost:3000` (Directly queries the populated `analytics` schema).
   * **PostgreSQL Engine:** Exposed on port `5432` (`airflow` / `airflow` / `airflow`).
