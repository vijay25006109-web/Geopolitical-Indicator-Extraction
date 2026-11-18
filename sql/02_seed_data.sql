-- Demonstration data only. Values are illustrative, not official statistics.
SET search_path TO geopolitics;

INSERT INTO countries (iso3, country_name, region, income_group) VALUES
('USA', 'United States', 'North America', 'High income'),
('CHN', 'China', 'East Asia', 'Upper middle income'),
('IND', 'India', 'South Asia', 'Lower middle income'),
('DEU', 'Germany', 'Europe', 'High income'),
('BRA', 'Brazil', 'South America', 'Upper middle income');

INSERT INTO indicators (indicator_code, indicator_name, category, unit, source_name) VALUES
('GDP_GROWTH', 'GDP growth rate', 'macroeconomic', 'percent', 'Demo dataset'),
('INFLATION', 'Consumer price inflation', 'macroeconomic', 'percent', 'Demo dataset'),
('UNEMPLOYMENT', 'Unemployment rate', 'macroeconomic', 'percent', 'Demo dataset'),
('POLITICAL_RISK', 'Political risk index', 'geopolitical', 'index_0_100', 'Demo dataset'),
('TRADE_OPEN', 'Trade openness', 'trade', 'percent_of_GDP', 'Demo dataset'),
('ENERGY_PRICE', 'Energy price index', 'energy', 'index', 'Demo dataset');

-- Annual sample observations for 2021-2023.
INSERT INTO indicator_observations
(country_id, indicator_id, observation_date, indicator_value, source_note)
SELECT c.country_id, i.indicator_id, v.observation_date, v.indicator_value, 'Illustrative training value'
FROM (VALUES
 ('USA','GDP_GROWTH',DATE '2021-12-31',5.9),('USA','GDP_GROWTH',DATE '2022-12-31',2.1),('USA','GDP_GROWTH',DATE '2023-12-31',2.5),
 ('CHN','GDP_GROWTH',DATE '2021-12-31',8.1),('CHN','GDP_GROWTH',DATE '2022-12-31',3.0),('CHN','GDP_GROWTH',DATE '2023-12-31',5.2),
 ('IND','GDP_GROWTH',DATE '2021-12-31',9.7),('IND','GDP_GROWTH',DATE '2022-12-31',7.0),('IND','GDP_GROWTH',DATE '2023-12-31',8.2),
 ('DEU','GDP_GROWTH',DATE '2021-12-31',3.7),('DEU','GDP_GROWTH',DATE '2022-12-31',1.4),('DEU','GDP_GROWTH',DATE '2023-12-31',-0.3),
 ('BRA','GDP_GROWTH',DATE '2021-12-31',5.0),('BRA','GDP_GROWTH',DATE '2022-12-31',3.0),('BRA','GDP_GROWTH',DATE '2023-12-31',2.9),

 ('USA','INFLATION',DATE '2021-12-31',4.7),('USA','INFLATION',DATE '2022-12-31',8.0),('USA','INFLATION',DATE '2023-12-31',4.1),
 ('CHN','INFLATION',DATE '2021-12-31',0.9),('CHN','INFLATION',DATE '2022-12-31',2.0),('CHN','INFLATION',DATE '2023-12-31',0.2),
 ('IND','INFLATION',DATE '2021-12-31',5.5),('IND','INFLATION',DATE '2022-12-31',6.7),('IND','INFLATION',DATE '2023-12-31',5.7),
 ('DEU','INFLATION',DATE '2021-12-31',3.1),('DEU','INFLATION',DATE '2022-12-31',6.9),('DEU','INFLATION',DATE '2023-12-31',5.9),
 ('BRA','INFLATION',DATE '2021-12-31',8.3),('BRA','INFLATION',DATE '2022-12-31',9.3),('BRA','INFLATION',DATE '2023-12-31',4.6),

 ('USA','POLITICAL_RISK',DATE '2021-12-31',18),('USA','POLITICAL_RISK',DATE '2022-12-31',20),('USA','POLITICAL_RISK',DATE '2023-12-31',19),
 ('CHN','POLITICAL_RISK',DATE '2021-12-31',35),('CHN','POLITICAL_RISK',DATE '2022-12-31',38),('CHN','POLITICAL_RISK',DATE '2023-12-31',40),
 ('IND','POLITICAL_RISK',DATE '2021-12-31',29),('IND','POLITICAL_RISK',DATE '2022-12-31',28),('IND','POLITICAL_RISK',DATE '2023-12-31',27),
 ('DEU','POLITICAL_RISK',DATE '2021-12-31',12),('DEU','POLITICAL_RISK',DATE '2022-12-31',13),('DEU','POLITICAL_RISK',DATE '2023-12-31',14),
 ('BRA','POLITICAL_RISK',DATE '2021-12-31',31),('BRA','POLITICAL_RISK',DATE '2022-12-31',33),('BRA','POLITICAL_RISK',DATE '2023-12-31',30)
) AS v(iso3, indicator_code, observation_date, indicator_value)
JOIN countries c ON c.iso3 = v.iso3
JOIN indicators i ON i.indicator_code = v.indicator_code;

-- Additional 2023 trade and energy indicators.
INSERT INTO indicator_observations
(country_id, indicator_id, observation_date, indicator_value, source_note)
SELECT c.country_id, i.indicator_id, DATE '2023-12-31', v.val, 'Illustrative training value'
FROM (VALUES
 ('USA','TRADE_OPEN',27.1),('CHN','TRADE_OPEN',37.0),('IND','TRADE_OPEN',46.0),('DEU','TRADE_OPEN',88.0),('BRA','TRADE_OPEN',33.0),
 ('USA','ENERGY_PRICE',112.0),('CHN','ENERGY_PRICE',108.0),('IND','ENERGY_PRICE',119.0),('DEU','ENERGY_PRICE',126.0),('BRA','ENERGY_PRICE',115.0)
) AS v(iso3, indicator_code, val)
JOIN countries c ON c.iso3 = v.iso3
JOIN indicators i ON i.indicator_code = v.indicator_code;
