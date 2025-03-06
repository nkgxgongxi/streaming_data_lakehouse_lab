USE DATABASE raw;

USE SCHEMA financial_info;

SELECT *
FROM NEWS_SOURCES
where category in ('technology', 'business')
and language = 'en';