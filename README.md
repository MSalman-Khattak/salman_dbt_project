<img width="3840" height="2400" alt="Screenshot (235)" src="https://github.com/user-attachments/assets/e7ab39e2-4f95-49b1-90fa-12ddeea3ade0" />
<img width="3840" height="2400" alt="Screenshot (236)" src="https://github.com/user-attachments/assets/23d4e13c-545d-4c10-bfd3-5481df6a1c0c" />
<img width="3840" height="2400" alt="Screenshot (237)" src="https://github.com/user-attachments/assets/13f58103-76e4-469e-b4b5-96875d5bcfbf" />
<img width="3840" height="2400" alt="Screenshot (238)" src="https://github.com/user-attachments/assets/6087ddc4-971f-45ff-b98f-7286036e9274" />
<img width="3840" height="2400" alt="Screenshot (239)" src="https://github.com/user-attachments/assets/d096b113-793d-440a-bfbf-2b53dfe536e2" />
# Salman DBT Practice Project

A production-deployed **dbt (data build tool)** project implementing a **Medallion Architecture** (Bronze → Silver → Gold) on **Databricks**, built end-to-end: raw ingestion, layered transformation, data quality testing, slowly changing dimension tracking, and multi-environment deployment.

![dbt](https://img.shields.io/badge/dbt-1.12.5-FF694B?logo=dbt)
![Databricks](https://img.shields.io/badge/Databricks-Delta%20Lake-FF3621?logo=databricks)
![Status](https://img.shields.io/badge/status-deployed-brightgreen)

---

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Core dbt Concepts Used](#core-dbt-concepts-used)
- [Setup](#setup)
- [Usage](#usage)
- [Models](#models)
- [Macros](#macros)
- [Testing Strategy](#testing-strategy)
- [Snapshots (SCD Type 2)](#snapshots-scd-type-2)
- [Environments & Deployment](#environments--deployment)
- [Lessons Learned](#lessons-learned)

---

## Overview

This project simulates a real-world analytics engineering workflow: ingesting raw sales, customer, product, store, and returns data from a source system, then progressively cleaning, enriching, testing, and aggregating it into analytics-ready datasets — deployed safely across **dev** and **production** Databricks environments.

## Architecture

```
Source System (source_schema)
        │
        ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│    BRONZE     │ ───▶ │    SILVER     │ ───▶ │     GOLD      │
│  Raw passthrough     │ Cleaned, joined,      │ Aggregated,   │
│  views               │ enriched tables       │ deduplicated, │
│                       │                       │ analytics-    │
│                       │                       │ ready tables  │
└───────────────┘      └───────────────┘      └───────────────┘
                                                        │
                                                        ▼
                                                 ┌───────────────┐
                                                 │   SNAPSHOTS   │
                                                 │ SCD Type 2    │
                                                 │ historical    │
                                                 │ tracking      │
                                                 └───────────────┘
```

| Layer | Purpose | Materialization | Example |
|-------|---------|------------------|---------|
| **Bronze** | Raw, minimally transformed data straight from source | View / Table | `bronze_sales`, `bronze_Dim_products` |
| **Silver** | Cleaned, joined, business-logic-enriched data | Table | `silver_sales_information` |
| **Gold** | Aggregated, deduplicated, analytics-ready datasets | Table | `source_gold_items` |
| **Snapshots** | Point-in-time historical change tracking | SCD Type 2 | `gold_items` |

## Tech Stack

- **dbt Core 1.12.5** — transformation framework
- **dbt-databricks 1.10.9** — Databricks adapter
- **Databricks** (Free Edition) — Delta Lake, Unity Catalog, Serverless SQL Warehouse
- **Python 3.11 + uv** — environment and package management
- **Git / GitHub** — version control

## Project Structure

```
salman_dbt_prac/
├── analyses/                  # Ad-hoc analytical queries (not materialized)
│   ├── macro_query.sql
│   └── target_variable.sql
├── macros/                    # Reusable Jinja macros
│   ├── generate_schema.sql    # Custom schema naming override
│   └── macro_multiplication_practice.sql
├── models/
│   ├── Bronze/                 # Raw source passthrough views/tables
│   │   ├── bronze_sales.sql
│   │   ├── bronze_Dim_customers.sql
│   │   ├── bronze_Dim_products.sql
│   │   ├── bronze_Dim_store.sql
│   │   ├── bronze_dim_date.sql
│   │   ├── bronze_returns.sql
│   │   └── properties.yml      # Column-level tests & docs
│   ├── silver/
│   │   └── silver_sales_information.sql
│   ├── Gold/
│   │   └── source_gold_items.sql
│   └── source/
│       └── sources.yml         # Source table declarations
├── seeds/                      # Static reference CSVs
│   └── lookup.csv
├── snapshots/                  # SCD Type 2 definitions
│   └── gold_items.yml
├── tests/                      # Custom singular data tests
│   └── only_positive_value_test.sql
├── dbt_project.yml
├── profiles.yml                 # Local only — gitignored
└── README.md
```

## Core dbt Concepts Used

This project intentionally covers the key concepts that define modern analytics engineering with dbt:

- **Medallion Architecture** — Bronze/Silver/Gold layering for progressive data refinement, now an industry-standard pattern (popularized by Databricks' lakehouse architecture).
- **`ref()` and `source()`** — all models reference each other via `{{ ref('model_name') }}` rather than hardcoded table names, building an automatic DAG (directed acyclic graph) of dependencies that dbt uses to run models in the correct order.
- **Jinja templating & macros** — reusable logic (`multiply_numbers`, custom `generate_schema_name`) instead of copy-pasted SQL.
- **Materializations** — `view` for lightweight Bronze passthroughs, `table` for heavier Silver/Gold transformations that benefit from pre-computation.
- **Generic vs. singular tests** — schema-defined tests (`unique`, `not_null`, `accepted_values`) for common checks, and custom SQL-based singular tests (`only_positive_value_test`) for business-specific rules.
- **Seeds** — version-controlled static/reference data (`lookup.csv`) loaded directly into the warehouse via `dbt seed`.
- **Snapshots & SCD Type 2** — tracking how dimensional data changes over time using the `timestamp` strategy, preserving full history rather than overwriting records.
- **Multi-environment targets** — `dev` and `prod` targets in `profiles.yml`, using `{{ target.catalog }}` instead of hardcoded catalog names so the same codebase deploys safely to either environment without modification.
- **`dbt build`** — a single command that runs seeds → models → snapshots → tests in dependency order, the modern recommended alternative to running each separately.
- **Data lineage** — dbt automatically generates a visual DAG (viewable via `dbt docs generate` or the VS Code dbt extension's Lineage tab) showing how data flows from raw sources through to final Gold models.

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
This file is intentionally **excluded from git** (it holds credentials) and must be created locally, with separate dev/prod targets:

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
    prod:
      type: databricks
      catalog: dbt_pract_prod
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
| `dbt run` | Build all models (dev target by default) |
| `dbt run -s silver_sales_information` | Build a single model |
| `dbt test` | Run all data tests |
| `dbt seed` | Load seed CSVs into Databricks |
| `dbt snapshot` | Run SCD Type 2 snapshots |
| `dbt build` | Run seeds, models, snapshots, and tests together, in dependency order |
| `dbt build --target prod` | Deploy the full project to the production catalog |
| `dbt compile --target prod` | Dry-run: resolve all Jinja/refs without executing, to catch errors before deploying |
| `dbt docs generate && dbt docs serve` | Generate and view interactive project documentation with lineage graph |

## Models

### Bronze Layer
Thin passthrough views/tables over raw source tables: `bronze_sales`, `bronze_Dim_customers`, `bronze_Dim_products`, `bronze_Dim_store`, `bronze_dim_date`, `bronze_returns`.

### Silver Layer — `silver_sales_information`
Joins sales with product and customer dimensions, calculates gross amounts via the custom `multiply_numbers` macro, and aggregates total gross sales by `category` and `gender`.

### Gold Layer — `source_gold_items`
Deduplicates item records using a `row_number()` window function, keeping the most recently updated row per item — a standard pattern for ensuring idempotent, current-state Gold tables.

## Macros

- **`multiply_numbers(col1, col2)`** — reusable Jinja macro that inlines a multiplication expression, demonstrating DRY (Don't Repeat Yourself) principles in SQL generation.
- **`generate_schema_name(custom_schema_name, node)`** — overrides dbt's default schema-naming behavior to use the custom schema directly (e.g. `bronze`, `silver`, `gold`) rather than dbt's default of appending it to the target schema.

## Testing Strategy

Data quality is enforced at multiple levels:

**Generic (schema) tests** — defined in `models/Bronze/properties.yml`:
- `unique` / `not_null` on primary keys (`sales_id`, `store_sk`)
- `accepted_values` on `store_name` and `Country` to validate against known reference lists

**Singular (custom SQL) tests** — defined in `tests/`:
- `only_positive_value_test` — validates that numeric business fields never contain invalid negative values

**Result**: 8/8 data tests passing in the production build.

## Snapshots (SCD Type 2)

The `gold_items` snapshot tracks historical changes to item records using dbt's `timestamp` strategy, keyed on `id` and driven by the `updated` column. This means every change to an item is preserved as a new row with `dbt_valid_from` / `dbt_valid_to` columns, rather than overwriting history — a standard data warehousing pattern for auditability and point-in-time analysis.

## Environments & Deployment

This project deploys cleanly across two isolated environments using Databricks' Unity Catalog:

| Target | Catalog | Purpose |
|---|---|---|
| `dev` | `dbt_dev` | Local development and iteration |
| `prod` | `dbt_pract_prod` | Production deployment |

Hardcoded catalog references were replaced with `{{ target.catalog }}` throughout `sources.yml` and snapshot configs, so the exact same code deploys correctly to either environment with no manual edits — a core best practice for safe, repeatable deployments.

**Latest production build**: 18/18 nodes succeeded — 1 seed, 1 snapshot, 5 table models, 8 data tests, 3 view models, completed with zero errors.

## Lessons Learned

Building this project surfaced several real-world engineering gotchas worth documenting:

- **Folder casing matters.** `dbt_project.yml` config paths (`Bronze`, `silver`, `Gold`) must exactly match actual folder names on disk — a mismatch causes silent "unused configuration path" warnings.
- **Windows is case-insensitive, Git is not.** This can cause Git to track duplicate paths for what Windows treats as a single file/folder, leading to confusing phantom diffs. Mitigated with `git config core.ignorecase false`.
- **Secrets must never be committed.** `profiles.yml` holds access tokens and is permanently gitignored. When a secret is accidentally committed, the correct remediation is: rotate the credential immediately, then use `git filter-repo` to scrub it from all history (not just the latest commit) before pushing.
- **`ref()` beats hardcoded joins.** Referencing a CTE or model incorrectly by its raw table name (instead of the aliased CTE) can silently "work" in some cases while bypassing intended transformation logic — a subtle bug worth testing for.

---

*Built as a hands-on practice project to learn modern analytics engineering patterns with dbt and Databricks.*
