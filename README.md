# Fashionable Analytics - Data Engineering Project

This repository contains a production-grade analytics data pipeline built atop the Fashionable Sales Report dataset, 
implementing a Kimball-style star schema to deliver clean, performant, and analytics-ready data marts. 
By applying dimensional modeling best practices, including conformed dimensions and degenerate facts , 
the pipeline transforms raw operational data into a structured warehouse optimized for marketing intelligence and self-service reporting. 
The resulting architecture enables stakeholders to run high-performance analytical queries that answer critical business questions, 
including: 
Which product styles and categories are most popular within specific cities or regions? 
How do sales volumes and gross revenue trend across seasonal, monthly, or promotional periods? 
What is the contribution of each product size, or promotional campaign to overall performance? etc
Each data mart is designed to be modular, self-contained, and portable — ready for consumption by BI tools, statistical analysis,.

## Data Loading and Exploration

The raw data was first loaded into duckdb(selected due to its portability and no sign-in) with a python script (using Visual Studio Code) and , 
explored directly in DuckDB to understand structure, quality, and the business meaning.

``` python load_to_duckdb.py ```

Note : removed unnamed column in the script itself

Exploration workflow :
	Schema inspection: Used DESCRIBE main.raw_sales to inspect column names, data types, and nullability.
	Profile queries: Ran SELECT * FROM information_schema.columns to catalog all available tables and their metadata.

Data profiling: 
	Executed ad-hoc SQL to check:
	Row counts and date ranges (MIN(order_date), MAX(order_date))
	Cardinality of key columns (COUNT(DISTINCT sales_key), COUNT(DISTINCT product_key))
	Null rates and data distributions
	Referential integrity between raw tables (e.g., do all product_keys in sales exist in the products table?)
	

## Architecture for dbt

Infrastructure :
- Terminal used : VS Code
- Database: DuckDB (single-file analytical database, zero external dependencies)
- Adapter: dbt-duckdb
- dbt version: 1.11.12

Key design decisions :
- Star schema over snowflake: Dimensions are denormalized to minimize JOIN complexity in BI tools and improve query performance.
- Surrogate keys used: All dimensions use hash-based surrogate keys. This isolates the warehouse from source system key changes and handles late-arriving dimensions gracefully.
- Degenerate dimensions: Transaction identifiers like order level attributes remain in fact tables rather than spawning one-column dimension tables.
- Slowly Changing Dimensions (SCD): product dimension use dbt snapshots to track historical changes over time (Type 2).
- Bus matrix alignment: The fact table shares conformed dimensions (dim_date, dim_product etc ), enabling consistent analysis across the business.

```
raw.raw_sales (DuckDB, loaded upstream via Python — outside this project)
        |
        v
staging/stg_fashionable_sales      (typed, renamed, 1:1)
        |
        v
intermediate/int_sales_enriched     (business rules, derived fields, surrogate keys)
        |
        +--> snapshots/dim_product_snapshot        --> marts/core/dim_product        (Type 2)
        +--> snapshots/dim_ship_location_snapshot  --> marts/core/dim_ship_location   (Type 2)
        |                                            marts/core/dim_fulfilment       (Type 1, junk dim)
        |                                            marts/core/dim_date             (generated)
        v
marts/core/fct_order_lines          (grain: one row per order_id + sku) also include sales data
        |
        v
marts/marketing/
    mart_sales_by_region
    mart_sales_by_category_style
    mart_seasonal_trends
    mart_channel_performance
	mart_top_products
	mart_promotion_performance
	mart_monthly_trends
	mart_size_performance
	mart_order_summary
	mart_location_repeat_activity
	mart_cancellation_deep_dive
	mart_weekday_performance
	
```

In addition to the above architecture, 
- Data quality is ensured through a layered testing framework. 
- Generic tests — defined in YAML to enforce structural integrity (e.g., primary key uniqueness, foreign key relationships, accepted value ranges). 
- Singular tests — custom SQL files in tests/ to validate complex business logic that cannot be expressed declaratively (e.g., "shipped amount should never exceed order amount"). 
- Reusable macros in macros/ centralize common logic such as surrogate key generation and seasonality classification, ensuring consistency across all models.
 
Together with configurations at model level, these mechanisms prevent bad data from propagating to downstream analytics. 
See tests/ and macros/ directories in the repo, and Testing strategy below for the detailed implementation.

**Grain of the fact table:** one row per order line.
Confirmed against real sample data, the same `Order ID` appears more
than once with different SKUs, so `order_id` alone can not be a valid key.

## How to run

```bash
# 1. Install dependencies (verify package versions of dbt-labs/dbt_utils and metaplane/dbt_expectations)
dbt deps

# 2. Staging and Intermediate must run before the snapshots that account for dim_product / dim_ship_location
dbt run -s stg_*
dbt run -s int_*

# 2. Snapshots must run before the marts that depend on dim_product / dim_ship_location, since those are built from snapshot tables
dbt snapshot

# 3. Build all models
dbt run

# fct_order_lines is incremental. First run builds it fully. On later
# runs, only new order_date rows are processed (see the model's SQL for
# the append-only assumption behind this). Force a full rebuild with:
#   dbt run --full-refresh --select fct_order_lines

# 4. Run tests
dbt test

# 5. Generate and view docs
dbt docs generate
dbt docs serve
```

`dbt seed` step is deliberately not done as the source is pre-loaded into `raw.raw_sales` by a
python script, to include the usage of python ,per project instructions.

## Data dictionary / lineage

Full column-level documentation lives in each layer's `.yml` file:
- `models/staging/sources.yml` — raw source columns
- `models/staging/stg_fashionable_sales.yml`
- `models/intermediate/int_sales_enriched.yml`
- `models/marts/core/_core.yml` — dims + fact
- `models/marts/marketing/_marketing.yml` — marts

Run `dbt docs generate && dbt docs serve` for the interactive lineage
graph (DAG) and searchable data dictionary.

## Assumptions & known limitations

These are explicit, documented judgment calls — not hidden defaults:

1. **No customer dimension.** The source has no customer identifier, only
   per-order ship-to details. Building a `dim_customer` / `mart_customer_ltv`
   would misrepresent the data, so this project scopes to
   order/region/category/seasonal/channel analysis instead, which matches the
   marketer questions actually posed in the brief.
2. **Date format** assumed `MM-DD-YY` based on the sample provided (a day
   value of 30 rules out `DD-MM`). Recommend re-validating against a full
   column profile before running against a different export.
3. **Season definition** uses US/European meteorological seasons
   (Winter=Dec–Feb, etc.) per an explicit project decision — even though
   the underlying data ships within India, where this mapping doesn't
   reflect local retail seasonality (e.g. monsoon, festive season). Worth
   calling out as a stated assumption in the presentation.
4. **`dim_ship_location` unique key is postal code.** Assumes a 1:1
   mapping between postal code and city/state at any point in time. This
   should be validated against the real data before trusting the Type-2
   history.
5. **`dim_product` unique key is SKU.** Assumes each SKU maps to exactly
   one (style, category, size, ASIN) combination at any point in time.
   The snapshot will error at run time if this doesn't hold — treat that
   as a real data-quality finding.
6. **Cancelled / zero-quantity lines** carry `amount = NULL`, not `0`, so
   downstream averages aren't silently understated. Enforced by a
   singular test (`tests/assert_cancelled_lines_have_no_amount.sql`).
7. **`accepted_values` tests** on `order_status` and `currency_code` were
   written from a small sample (~30 rows), not a full profile set to
   `warn` severity intentionally until validated against the complete
   dataset.
8. **Package versions** in `packages.yml` and adapter-specific syntax
   (DuckDB `strptime`, snapshot config keys, `dbt_utils.date_spine`
   signature) are written to the best of my knowledge but not verified
   against a live install — please confirm against current docs and your
   installed versions before running.
9. **Ship-location casing normalization** upper-cases city/state/country
   rather than title-casing them, because I'm not fully certain
   `initcap()` exists in all DuckDB versions and didn't want to rely on
   an unverified function for a data-cleaning step. Trade readability for
   reliability — swap to `initcap()` once confirmed available if
   preferred.
10. **Incremental watermark on `fct_order_lines`** assumes the raw source
    is append-only (new rows only ever have a later `order_date` than
    what's already loaded). If historical corrections can arrive with an
    old `order_date`, this would miss them — see the model's SQL for the
    full flag and the fallback (`--full-refresh`).
11. **CI scope**: the GitHub Actions workflow validates the project
    compiles (`dbt parse`/`dbt compile`), not that it runs correctly
    against real data (`dbt run`/`dbt test`) — see that workflow file's
    header comment for why, and what's needed to extend it.

## CI/CD

The repository includes a GitHub Actions workflow `.github/workflows/dbt_ci.yml` that executes on every push and pull request to `main`. 
It runs `dbt deps`, `dbt parse`, and `dbt compile` to validate the entire project: 
every macro resolves correctly, every ref() and source() points to a valid object, and every model's SQL is syntactically sound. 
This "thin CI" approach requires no live database connection, making it fast, cost-free, and safe for open-source or assessment environments. 
It intentionally does not execute dbt run or dbt test. These steps require a seeded fixture database, service account credentials, and secrets management. 
See the comment header in the workflow file for the full rationale and a checklist of what a production-grade CI/CD pipeline would need to add

## Data cleaning

Beyond typing/renaming, `stg_fashionable_sales` has an explicit cleaning
step: For example :
- `ship_city` / `ship_state` / `ship_country` are trimmed and upper-cased.
  This was a real, visible issue in the sample data provided , the same
  city appeared as `MUMBAI` (all-caps) and `Bengaluru`/`Hyderabad`
  (mixed-case). Left as-is, that would fragment one real city into
  multiple `dim_ship_location` rows and silently split revenue across
  them in the region mart.
- All text fields are trimmed of whitespace.
- An exact-duplicate-row guard drops byte-for-byte duplicate source rows
  (a known real-world CSV export issue), without touching legitimate
  `(order_id, sku)` pairs that differ in any other column.

## Incremental logic & data contracts (DataOps)

- `fct_order_lines` is built as an **incremental** model (watermarked on
  `order_date`), rather than `table`/`view` — this is the model where
  incremental logic actually matters at real data volume. See the
  assumption flagged in that model's SQL about append-only source data.
- `fct_order_lines` also has a **dbt model contract enforced**
  (`config: contract: {enforced: true}` with full column/data-type
  declarations in `_core.yml`). This makes the fact table's shape a
  real, build-breaking interface rather than just a description, 
  applied to the highest-value model first, not blanket-applied
  everywhere.

## Testing Strategy

- **Structural**: `unique`/`not_null` on all primary keys; `relationships`
  tests on every FK from `fct_order_lines` to its dimensions.
- **Composite-key validation**: `dbt_utils.unique_combination_of_columns`
  on `(order_id, sku)` in staging, and on each mart's stated grain
  (`ship_state/ship_city/category`, `category/style/size`,
  `season/order_year/category`, `fulfilment/sales_channel/ship_service_level/is_b2b`)
  — this is the test that actually proves each grain claim, not just an
  assertion in a description field.
- **Business-rule tests**: for example, a custom generic test
  (`non_negative_or_null`) and a singular test enforcing the
  cancelled-order/null-amount rule.
- **Join-integrity test**: `assert_fact_row_count_matches_source.sql`
  guards against fan-out from the point-in-time joins to the Type-2 dims since a date-range overlap bug
  would silently duplicate fact rows.
- **SSOT reconciliation tests**: for example,`assert_mart_revenue_reconciles_to_fact.sql`
  checks that `mart_sales_by_region`'s total revenue ties back exactly to
  `fct_order_lines`, so a future change to mart aggregation logic can't
  silently drift from the source of truth.similarly for `assert_order_summary_reconciles_to_fact`
- **Distributional checks**: `dbt_expectations` bounds on `quantity`, set
  to `warn` rather than `error` since they're sanity checks, not hard
  contracts.
  
## Visualization Strategy

Power BI is/ can be used as it is an open source tool.
The 12 data marts are exported as parquet files, for less storage and portability (no dependencies) and performance from duckdb,
which will be the source for Power BI dashboards.Just one dimension is used to create a slicer across all pages.
The data marts are independent of each other and simple individual charts are made using these marts. 
See the PowerBI file in the repo for a clearer picture.
  

## Known gaps / future improvements

- Freshness checks on the source are omitted because the raw load has no
  `loaded_at` column exposed to dbt which add one upstream if freshness SLAs matter.
- Data Privacy & Customer Analytics: The current dataset does not contain any customer-level personally identifiable information (PII). 
  While this ensures compliance with data privacy standards, it limits the ability to perform customer-centric analyses such as cohort retention, 
  lifetime value (LTV) modeling, or churn prediction. Future iterations could incorporate privacy-compliant customer identifiers 
  to unlock deeper behavioral insights.
- Future Architecture & Streaming: The current pipeline is built for batch processing. 
  If the source system transitions to an API-based data feed, the architecture can be extended to support streaming analytics. 
  This would enable near real-time reporting and could incorporate modern orchestration tools such as Apache Airflow or Dagster for pipeline scheduling, monitoring, and dependency management.
