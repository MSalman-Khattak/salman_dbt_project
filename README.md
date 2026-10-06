# Salman DBT Practice Project

A dbt (data build tool) project implementing a **Medallion Architecture** (Bronze → Silver → Gold) on **Databricks**, built to practice data transformation, testing, and modeling patterns for an analytics engineering workflow.

## Overview

This project ingests raw sales, customer, product, store, and returns data, then progressively cleans, enriches, and aggregates it through three layers:

| Layer | Purpose | Materialization |
|-------|---------|------------------|
| **Bronze** | Raw, minimally transformed data straight from source | View |
| **Silver** | Cleaned, joined, and business-logic-enriched data | Table |
| **Gold** | Aggregated, analytics-ready datasets for reporting | Table / Snapshot |

## Tech Stack

- **dbt Core** (1.12.x)
- **Databricks** (SQL Warehouse, Delta Lake)
- **Python** / **uv** for environment management
- **Git** / **GitHub** for version control

## Project Structure

```
salman_dbt_prac/
├── models/
│   ├── Bronze/              # Raw source passthrough views
│   │   ├── bronze_sales.sql
│   │   ├── bronze_Dim_customers.sql
│   │   ├── bronze_Dim_products.sql
│   │   ├── bronze_Dim_store.sql
│   │   ├── bronze_dim_date.sql
│   │   ├── bronze_returns.sql
│   │   └── properties.yml   # Bronze model tests & column configs
│   ├── silver/               # Cleaned, joined, enriched models
│   │   └── silver_sales_information.sql
│   ├── Gold/                 # Aggregated, analytics-ready models
│   │   └── source_gold_items.sql
│   └── source/
│       └── sources.yml       # Source table declarations
├── macros/                   # Custom Jinja macros
│   ├── generate_schema_name.sql
│   └── multiply_numbers.sql
├── seeds/                    # Static reference CSVs loaded via `dbt seed`
├── snapshots/                # SCD Type 2 snapshots
│   └── gold_items.yml
├── tests/                    # Custom singular tests
├── analyses/
├── dbt_project.yml
└── profiles.yml              # NOT committed — see Setup below
```

## Setup

### Prerequisites
- Python 3.11+
- [uv](https://docs.astral.sh/uv/) package manager
- A Databricks workspace with a SQL Warehouse and a personal access token

### 1. Clone the repo
```bash
git clone https://github.com/MSalman-Khattak/salman_dbt_project.git
cd salman_dbt_project/salman_dbt_prac
```

### 2. Set up the environment
```bash
uv venv
.venv\Scripts\activate      # Windows
pip install dbt-databricks
```

### 3. Configure `profiles.yml`
This file is intentionally **excluded from git** (it holds credentials) and must be created locally:

```yaml
salman_dbt_prac:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: dbt_dev
      schema: default
      host: <your-databricks-host>
      http_path: <your-sql-warehouse-http-path>
      token: <your-databricks-access-token>
      threads: 4
```

Place this at `salman_dbt_prac/profiles.yml`.

### 4. Verify the connection
```bash
dbt debug
```

## Usage

| Command | Purpose |
|---|---|
| `dbt run` | Build all models |
| `dbt run -s silver_sales_information` | Build a single model |
| `dbt test` | Run all data tests |
| `dbt seed` | Load seed CSVs into Databricks |
| `dbt snapshot` | Run SCD Type 2 snapshots |
| `dbt build` | Run seeds, models, snapshots, and tests together |
| `dbt docs generate && dbt docs serve` | Generate and view project documentation |

## Models

### Bronze Layer
Thin passthrough views (`select * from {{ source(...) }}`) over raw source tables: sales, customers, products, store, date, and returns.

### Silver Layer — `silver_sales_information`
Joins sales with product and customer dimensions, calculates gross amounts via the custom `multiply_numbers` macro, and aggregates total gross sales by `category` and `gender`.

### Gold Layer — `source_gold_items`
Deduplicates item records using a `row_number()` window function, keeping the most recently updated row per item.

### Snapshots — `gold_items`
SCD Type 2 snapshot tracking historical changes to gold item records using the `timestamp` strategy on an `updated_at` column.

## Macros

- **`multiply_numbers(col1, col2)`** — reusable Jinja macro for multiplying two columns.
- **`generate_schema_name(custom_schema_name, node)`** — overrides dbt's default schema naming to use the custom schema directly rather than appending it to the target schema.

## Testing

Data quality is enforced via generic dbt tests defined in `models/Bronze/properties.yml`:
- `unique` / `not_null` on primary keys (`sales_id`, `store_sk`)
- `accepted_values` on `store_name` to validate against a known list of store locations

## Notes

- Folder casing matters in `dbt_project.yml` — model config paths (`Bronze`, `silver`, `Gold`) must exactly match the actual folder names on disk.
- `profiles.yml` must never be committed — it's gitignored. If a token is ever accidentally committed, rotate it immediately in Databricks and scrub it from git history before pushing.

## License

Personal practice project — no license specified.
