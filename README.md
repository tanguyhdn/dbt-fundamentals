# dbt Fundamentals – Jaffle Shop Project (BigQuery Edition) + dbtf (VS Code)

Following dbt Labs – dbt Fundamentals (VS Code) while using Google BigQuery and dbt-fusion (dbtf) instead of Snowflake.

## Project overview

This project is my implementation of the dbt Fundamentals learning course.
It demonstrates how to build a modern analytics workflow using dbt (via dbt-fusion), BigQuery, and VS Code.

The project models data from the Jaffle Shop, a fictional e-commerce business.
It transforms raw data from operational sources (Jaffle Shop & Stripe) into clean, analytics-ready tables for reporting and insights.

## Tech Stack

| Component                   | Tool                         |
| --------------------------- | ---------------------------- |
| **Data Warehouse**          | Google BigQuery              |
| **Transformation Layer**    | dbt (dbt-fusion CLI)         |
| **Development Environment** | VS Code (Windows 11)         |
| **Version Control**         | Git / GitHub                 |
| **Language**                | SQL + Jinja (for dbt models) |

### Project Structure

dbt_fundamentals/
├── models/
│   ├── staging/
│   │   ├── stg_jaffle_shop__customers.sql
│   │   ├── stg_jaffle_shop__orders.sql
│   │   └── stg_stripe__payments.sql
│   ├── marts/
│   │   └── dim_customers.sql
│   └── _src_jaffle_shop.yml
├── macros/
├── seeds/
├── snapshots/
├── dbt_project.yml
├── README.md
└── .dbt/
    └── profiles.yml

- staging/ → cleans and renames raw source tables
- marts/ → combines staging models into analytics-ready datasets (dimensions / facts)
- macros/ → reusable SQL logic (if any)
- seeds/ → optional CSV files for static data

## 🧠 Learning Goals

- Understand dbt’s core concepts: models, sources, refs, tests, and documentation.
- Learn to structure a project using staging → marts layers.
- Practice Jinja templating for dynamic SQL.
- Manage environments and profiles for BigQuery instead of Snowflake.
- Run and debug dbt commands using dbt-fusion in VS Code.