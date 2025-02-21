
-- Use the `ref` function to select from other models
-- my personal test, trying to see if the table created in target database is the name of the script.

select *
from {{ ref('my_first_dbt_model') }}
where id = 1