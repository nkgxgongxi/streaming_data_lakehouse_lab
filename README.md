## My First Data Lakehouse for Streaming

Author: Xi Gong

Last updated at: 2025-02-18

## Project Summary

This is one of my practice projects aiming to setup a Data Lakehouse on AWS infrastructure. 
In this project, I have experimented with the following techniques. 
1. Use Kafka Connect (JDBC Source Connector) to digest data in a streaming fashion. Even though my source data are from AWS RDS PostgreSQL database, I am using this configuration to understand how Kafka processes data.
2. Setup AWS RDS database. This is among the first times I am using a AWS managed service instead of setting things up all by myself (on an EC2 instance). 
3. Use Infrastructure as Code approach, specifically, Terraform, to deploy various services, including Kafka, RDS and S3.
4. Try to connect the source data with a Databricks account for ETL process.
5. Further tested dbt on my Snowflake account. 

### Future work
- read data from API, load into Snowflake/S3.
- Use the recent learning such as Snowflake task, dbt, Databricks to perform ETL tasks, or more specifically transformation tasks. 
- Establish an Airflow server to automate the workflow. 
- Use Github actions to automate the deployment process.