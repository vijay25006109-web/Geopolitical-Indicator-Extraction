"""
Python DB-API runner for the Geopolitical Indicator Analytics project.

Prerequisites:
    PostgreSQL database created, then run sql/01_schema.sql and sql/02_seed_data.sql.
    pip install -r requirements.txt

Set environment variables:
    PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD

Example (PowerShell):
    $env:PGDATABASE="geopolitics_db"
    $env:PGUSER="postgres"
    $env:PGPASSWORD="your_password"
    python python/run_queries.py
"""
import os
import time
import psycopg2
from psycopg2.extras import RealDictCursor

QUERIES = {
    "GDP growth ranking and year-on-year change": """
        SELECT c.country_name, o.observation_date, o.indicator_value AS gdp_growth,
               LAG(o.indicator_value) OVER (
                   PARTITION BY c.country_id ORDER BY o.observation_date
               ) AS previous_value,
               RANK() OVER (
                   PARTITION BY o.observation_date ORDER BY o.indicator_value DESC
               ) AS growth_rank
        FROM geopolitics.indicator_observations o
        JOIN geopolitics.countries c ON c.country_id = o.country_id
        JOIN geopolitics.indicators i ON i.indicator_id = o.indicator_id
        WHERE i.indicator_code = %s
        ORDER BY o.observation_date, growth_rank
    """,
    "Latest macroeconomic and geopolitical snapshot": """
        WITH ranked AS (
            SELECT o.country_id, o.indicator_id, o.observation_date, o.indicator_value,
                   ROW_NUMBER() OVER (
                       PARTITION BY o.country_id, o.indicator_id
                       ORDER BY o.observation_date DESC
                   ) AS rn
            FROM geopolitics.indicator_observations o
        )
        SELECT c.country_name, i.indicator_name, r.observation_date, r.indicator_value
        FROM ranked r
        JOIN geopolitics.countries c ON c.country_id = r.country_id
        JOIN geopolitics.indicators i ON i.indicator_id = r.indicator_id
        WHERE r.rn = 1
        ORDER BY c.country_name, i.category
    """
}

def connect():
    """Connect using PostgreSQL environment variables (no credentials hard-coded)."""
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "geopolitics_db"),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", "")
    )

def print_rows(title, rows):
    print("\\n" + "=" * 88)
    print(title)
    print("=" * 88)
    for row in rows:
        print(dict(row))

def main():
    with connect() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            for title, sql in QUERIES.items():
                start = time.perf_counter()
                if title.startswith("GDP"):
                    cur.execute(sql, ("GDP_GROWTH",))
                else:
                    cur.execute(sql)
                rows = cur.fetchall()
                elapsed_ms = (time.perf_counter() - start) * 1000
                print_rows(title, rows)
                print(f"Rows returned: {len(rows)} | Python-measured elapsed: {elapsed_ms:.3f} ms")

            benchmark_sql = """
                SELECT COUNT(*)
                FROM geopolitics.indicator_observations o
                JOIN geopolitics.countries c ON c.country_id = o.country_id
                JOIN geopolitics.indicators i ON i.indicator_id = o.indicator_id
                WHERE c.iso3 = %s AND i.category = %s
                  AND o.observation_date >= %s
            """
            timings = []
            for _ in range(10):
                start = time.perf_counter()
                cur.execute(benchmark_sql, ("IND", "macroeconomic", "2021-01-01"))
                cur.fetchone()
                timings.append((time.perf_counter() - start) * 1000)
            print("\\nBenchmark (10 repetitions):")
            print(f"Mean: {sum(timings)/len(timings):.3f} ms | Min: {min(timings):.3f} ms | Max: {max(timings):.3f} ms")
            print("For database-side plan and buffer metrics, run sql/03_advanced_queries.sql Q6.")

if __name__ == "__main__":
    main()
