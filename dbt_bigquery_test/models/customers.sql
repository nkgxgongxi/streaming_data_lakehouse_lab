-- following the tutorial, create a view using the external tables from dbt-tutorial
-- when I first run dbt run with this sql file, because I already created a table with the same name, I got the following error: 
-- Trying to create view `dbt-bigquery-test1-451708`.`jaffle_shop`.`customers`, but it currently exists as a table. Either drop `dbt-bigquery-test1-451708`.`jaffle_shop`.`customers` manually, or run dbt with `--full-refresh` and dbt will drop it for you.
-- By adding --full-refresh, I was able to overwrite the table by this view.

-- further tried following instruction to override the target to view instead of table for this model.

with customers as (

    select * from {{ref('stg_customers')}}

),

orders as (

    select * from {{ref('stg_orders')}}

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