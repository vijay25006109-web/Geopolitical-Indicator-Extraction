-- Geopolitical Indicator Extraction via Advanced SQL
-- PostgreSQL schema | DBMS for Analytics - Module 2

CREATE SCHEMA IF NOT EXISTS geopolitics;
SET search_path TO geopolitics;

DROP TABLE IF EXISTS indicator_observations CASCADE;
DROP TABLE IF EXISTS indicators CASCADE;
DROP TABLE IF EXISTS countries CASCADE;

CREATE TABLE countries (
    country_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    iso3             CHAR(3) NOT NULL UNIQUE,
    country_name     VARCHAR(100) NOT NULL,
    region           VARCHAR(60) NOT NULL,
    income_group     VARCHAR(40),
    CONSTRAINT chk_iso3_upper CHECK (iso3 = UPPER(iso3))
);

CREATE TABLE indicators (
    indicator_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    indicator_code   VARCHAR(30) NOT NULL UNIQUE,
    indicator_name   VARCHAR(120) NOT NULL,
    category         VARCHAR(50) NOT NULL,
    unit             VARCHAR(40) NOT NULL,
    source_name      VARCHAR(120) NOT NULL,
    CONSTRAINT chk_indicator_category
        CHECK (category IN ('macroeconomic', 'geopolitical', 'trade', 'energy'))
);

CREATE TABLE indicator_observations (
    observation_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_id       INTEGER NOT NULL REFERENCES countries(country_id),
    indicator_id     INTEGER NOT NULL REFERENCES indicators(indicator_id),
    observation_date DATE NOT NULL,
    indicator_value NUMERIC(18,4) NOT NULL,
    source_note      TEXT,
    ingested_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_country_indicator_date
        UNIQUE (country_id, indicator_id, observation_date),
    CONSTRAINT chk_observation_date
        CHECK (observation_date >= DATE '1990-01-01')
);

-- Indexes support common filtering, joins and time-series ordering.
CREATE INDEX idx_observations_country_date
    ON indicator_observations(country_id, observation_date DESC);
CREATE INDEX idx_observations_indicator_date
    ON indicator_observations(indicator_id, observation_date DESC);
CREATE INDEX idx_indicators_category
    ON indicators(category);

-- Useful for planner statistics after loading larger datasets:
-- ANALYZE geopolitics.indicator_observations;
