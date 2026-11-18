# Geopolitical Indicator Extraction via Advanced SQL

**Curriculum:** DBMS for Analytics — Module 2  
**Tools:** PostgreSQL, Python DB-API (`psycopg2`)  
**Proof:** Raw SQL calculation sheet and Python script with query outputs.

## Project contents

- `sql/01_schema.sql` — relational schema, primary/foreign keys, unique and check constraints, indexes.
- `sql/02_seed_data.sql` — illustrative sample records for five countries and six indicators.
- `sql/03_advanced_queries.sql` — multi-table joins, scalar/correlated subqueries, CTEs, window functions, and `EXPLAIN ANALYZE`.
- `python/run_queries.py` — DB-API execution, parameterized queries, displayed results, and timing benchmark.
- `data/` — reserved for authorized raw source datasets.
- `reports/` — reserved for captured benchmark output and query results.

## Important data note

The included country indicator values are **illustrative training values**, not official macroeconomic or geopolitical statistics. For a real analysis, replace them with verified data from authoritative sources and document the source, units, date frequency, and revision vintage. Do not interpret the sample political-risk values as a real-world country ranking.

## 1. Create the database

In `psql`:

```sql
CREATE DATABASE geopolitics_db;
```

Connect to it, then run the scripts in order:

```bash
psql -d geopolitics_db -f sql/01_schema.sql
psql -d geopolitics_db -f sql/02_seed_data.sql
```

Run advanced SQL:

```bash
psql -d geopolitics_db -f sql/03_advanced_queries.sql
```

## 2. Configure Python

```bash
python -m pip install -r requirements.txt
```

Set connection environment variables. Example in PowerShell:

```powershell
$env:PGHOST="localhost"
$env:PGPORT="5432"
$env:PGDATABASE="geopolitics_db"
$env:PGUSER="postgres"
$env:PGPASSWORD="your_password"
```

Run:

```bash
python python/run_queries.py
```

Credentials are read from environment variables; do not commit passwords to GitHub.

## 3. SQL concepts demonstrated

1. **Schema design:** normalized country, indicator metadata, and observation tables.
2. **Constraints:** primary keys, foreign keys, unique natural key, and check constraints.
3. **JOIN:** combine observation values with country and indicator metadata.
4. **Subqueries:** compare latest GDP growth with the cross-country average.
5. **Window functions:** `LAG`, `RANK`, and `ROW_NUMBER`.
6. **Aggregation:** `FILTER` conditional aggregation for latest indicator snapshots.
7. **Performance:** B-tree indexes, Python elapsed-time benchmarking, and PostgreSQL `EXPLAIN (ANALYZE, BUFFERS)`.

## 4. Benchmarking notes

The Python script executes a parameterized query ten times and reports mean, minimum, and maximum elapsed time. This measures client-observed execution time for the small demonstration dataset and includes network/driver overhead. For query-plan analysis, use the `EXPLAIN (ANALYZE, BUFFERS)` query in `03_advanced_queries.sql`.

For a fair index comparison on a larger dataset:
- load a sufficiently large dataset;
- run `ANALYZE geopolitics.indicator_observations`;
- capture `EXPLAIN (ANALYZE, BUFFERS)` before and after adding indexes;
- compare actual execution time, rows, and buffer reads;
- repeat several times and report median/mean, noting cache effects.

## 5. Suggested repository layout

```text
Geopolitical-Indicator-Extraction-Advanced-SQL/
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   └── 03_advanced_queries.sql
├── python/
│   └── run_queries.py
├── data/
├── reports/
├── requirements.txt
└── README.md
```
