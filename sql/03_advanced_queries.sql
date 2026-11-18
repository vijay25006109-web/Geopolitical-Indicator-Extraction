-- Advanced SQL calculation sheet
SET search_path TO geopolitics;

-- Q1. Multi-table JOIN: show macro and geopolitical indicators by country/date.
SELECT c.country_name, c.region, i.indicator_name, i.category,
       o.observation_date, o.indicator_value, i.unit
FROM indicator_observations o
JOIN countries c ON c.country_id = o.country_id
JOIN indicators i ON i.indicator_id = o.indicator_id
WHERE o.observation_date >= DATE '2022-01-01'
ORDER BY c.country_name, i.category, o.observation_date;

-- Q2. Subquery: countries whose latest GDP growth is above the cross-country average.
WITH latest_gdp AS (
    SELECT DISTINCT ON (o.country_id)
           o.country_id, o.indicator_value AS gdp_growth, o.observation_date
    FROM indicator_observations o
    JOIN indicators i ON i.indicator_id = o.indicator_id
    WHERE i.indicator_code = 'GDP_GROWTH'
    ORDER BY o.country_id, o.observation_date DESC
)
SELECT c.country_name, lg.gdp_growth, lg.observation_date
FROM latest_gdp lg
JOIN countries c ON c.country_id = lg.country_id
WHERE lg.gdp_growth > (SELECT AVG(gdp_growth) FROM latest_gdp)
ORDER BY lg.gdp_growth DESC;

-- Q3. Window function: year-on-year change and country ranking for GDP growth.
SELECT c.country_name, o.observation_date, o.indicator_value AS gdp_growth,
       LAG(o.indicator_value) OVER (
           PARTITION BY c.country_id ORDER BY o.observation_date
       ) AS previous_value,
       ROUND((o.indicator_value - LAG(o.indicator_value) OVER (
           PARTITION BY c.country_id ORDER BY o.observation_date
       ))::numeric, 2) AS change_from_previous,
       RANK() OVER (
           PARTITION BY o.observation_date ORDER BY o.indicator_value DESC
       ) AS growth_rank_for_date
FROM indicator_observations o
JOIN countries c ON c.country_id = o.country_id
JOIN indicators i ON i.indicator_id = o.indicator_id
WHERE i.indicator_code = 'GDP_GROWTH'
ORDER BY o.observation_date, growth_rank_for_date;

-- Q4. Conditional aggregation: latest inflation and political-risk values per country.
WITH latest AS (
    SELECT DISTINCT ON (o.country_id, o.indicator_id)
           o.country_id, o.indicator_id, o.indicator_value, o.observation_date
    FROM indicator_observations o
    ORDER BY o.country_id, o.indicator_id, o.observation_date DESC
)
SELECT c.country_name,
       MAX(l.indicator_value) FILTER (WHERE i.indicator_code = 'INFLATION') AS latest_inflation_pct,
       MAX(l.indicator_value) FILTER (WHERE i.indicator_code = 'POLITICAL_RISK') AS latest_political_risk
FROM latest l
JOIN countries c ON c.country_id = l.country_id
JOIN indicators i ON i.indicator_id = l.indicator_id
GROUP BY c.country_name
ORDER BY latest_political_risk DESC;

-- Q5. Correlated subquery: latest observation for each country-indicator pair.
SELECT c.country_name, i.indicator_name, o.observation_date, o.indicator_value
FROM indicator_observations o
JOIN countries c ON c.country_id = o.country_id
JOIN indicators i ON i.indicator_id = o.indicator_id
WHERE o.observation_date = (
    SELECT MAX(o2.observation_date)
    FROM indicator_observations o2
    WHERE o2.country_id = o.country_id
      AND o2.indicator_id = o.indicator_id
)
ORDER BY c.country_name, i.indicator_name;

-- Q6. EXPLAIN ANALYZE: inspect execution plan and actual runtime.
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.country_name, i.indicator_name, o.observation_date, o.indicator_value
FROM indicator_observations o
JOIN countries c ON c.country_id = o.country_id
JOIN indicators i ON i.indicator_id = o.indicator_id
WHERE c.iso3 IN ('USA', 'IND', 'CHN')
  AND i.category IN ('macroeconomic', 'geopolitical')
  AND o.observation_date BETWEEN DATE '2021-01-01' AND DATE '2023-12-31';
