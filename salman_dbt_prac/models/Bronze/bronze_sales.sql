{{ config(
    materialized='view'
) }}

select 
    *
From 
    {{ source('source_schema', 'fact_sales') }}