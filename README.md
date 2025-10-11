# dbt Fundamentals – Jaffle Shop Project (BigQuery Edition) + dbtf (VS Code)

Following dbt Labs – dbt Fundamentals (VS Code) while using Google BigQuery and dbt-fusion (dbtf) instead of Snowflake.

## 🧠 Learning Goals

- Understand dbt’s core concepts: models, sources, refs, tests, and documentation.
- Learn to structure a project using staging → marts layers.
- Practice Jinja templating for dynamic SQL.
- Manage environments and profiles for BigQuery instead of Snowflake.
- Run and debug dbt commands using dbt-fusion in VS Code.

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

```
dbt_fundamentals/
├── models/
│   ├── staging/                        # Source-level cleaning and renaming
│   │   ├── jaffle_shop/
│   │   │   ├── _src_jaffle_shop.yml
│   │   │   ├── _stg_jaffle_shop.yml
│   │   │   ├── jaffle_shop_docs.md
│   │   │   ├── stg_jaffle_shop__customers.sql
│   │   │   └── stg_jaffle_shop__orders.sql
│   │   └── stripe/
│   │       ├── _src_stripe.yml
│   │       └── stg_stripe__payments.sql
│   │
│   └── marts/                          # Business-level aggregations and dimensions
│       ├── dim_customers.sql
│       └── finance/
│           └── fct_orders.sql
│
├── tests/
│   └── assert_stg_stripe__payment_total_positive.sql
│
├── dbt_project.yml
├── README.md
└── .dbt/
    └── profiles.yml

```

## Folder roles

```
| Folder                          | Purpose                                                         |
| ------------------------------- | --------------------------------------------------------------- |
| **models/staging/**             | Cleans raw data from Jaffle Shop & Stripe sources               |
| **models/staging/jaffle_shop/** | Models and source definitions for the `raw_jaffle_shop` dataset |
| **models/staging/stripe/**      | Models and source definitions for the `raw_stripe` dataset      |
| **models/marts/**               | Contains final business-ready models (dimensions & facts)       |
| **models/marts/finance/**       | Holds finance-specific aggregations such as `fct_orders`        |
| **tests/**                      | Custom data tests beyond the default dbt schema tests           |
| **.dbt/**                       | Contains your dbt `profiles.yml` (connection to BigQuery)       |

```

## Setup (BigQuery + dbtf)

Replace YOUR_PROJECT_ID with your GCP project (e.g. jaffle-sshop). Target dataset is analytics.

### 1 - dbt_project.yml (excerpt)
```
name: 'jaffle_shop'
version: '1.0.0'
config-version: 2

profile: 'jaffleshop'

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"  # directory which will store compiled SQL files
clean-targets:         # directories to be removed by `dbt clean`
    - "target"
    - "dbt_modules"


models:
  jaffle_shop:
    staging:
      +materialized: view
    marts:
      +materialized: table
```
## 2) Project-scoped profile (.dbt/profiles.yml)
```
default:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      keyfile: D:/path/to/service-account.json
      database: YOUR_PROJECT_ID
      schema: analytics
      location: europe-west1
      threads: 8
```
## Sources (public Jaffle Shop dataset)

Declare the public sources and reference them with source():

dbt_fundamentals/models/staging/jaffle_shop/_src_jaffle_shop.yml
```
sources:
  - name: raw_jaffle_shop
    description: A clone of a Postgres database
    database: jaffle-sshop
    schema: raw_jaffle_shop
    tables:
      - name: customers
        description: Raw customers data
        columns:
          - name: id
            description: primary key
            data_tests:
              - unique
              - not_null
      - name: orders
        config:
          freshness:
            warn_after:
              count: 7
              period: day
            error_after: 
              count: 30
              period: day
          loaded_at_field: _etl_loaded_at
```

## Example model

```
with customers as (

    select * from {{ ref('stg_jaffle_shop__customers')}}

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders')}}

),

customer_orders as (

    select
        customer_id,

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders

    from orders

    group by 1

),


final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders

    from customers

    left join customer_orders using (customer_id)

)

select * from final
```

## Common commands (dbtf)

```
dbtf debug             # config & connectivity
dbtf deps              # install packages (if packages.yml exists)
dbtf ls                # list nodes

# Build
dbtf build             # run + test + seed + snapshot + docs generate
# or
dbtf seed              # load CSVs from ./seeds into BigQuery
dbtf run               # run models
dbtf test              # run tests

# Selection examples
dbtf run --select models/staging
dbtf run --select tag:mart
dbtf source freshness

```

## Troubleshooting

- **Profile 'jaffleshop' not found** → Ensure profile: 'jaffleshop' in dbt_project.yml and top-level key jaffleshop: in ./.dbt/profiles.yml. VS Code should use DBT_PROFILES_DIR=./.dbt.

- **Catalog 'raw' does not exist** → On BigQuery, catalog = project, schema = dataset. Use {{ source() }} or a fully qualified table like `{{ target.database }}`.dataset.table.

- **403 Access Denied (dbt-tutorial)** → Use OAuth (method: oauth + gcloud auth application-default login) to read the public dataset.

- **Stale source** → Loosen thresholds (warn 7d, error 30d) or remove freshness during the course.

- **Wrong profiles file loaded** → dbtf debug should print Loading .dbt\profiles.yml. If it shows ~/.dbt/profiles.yml, set the workspace env var.