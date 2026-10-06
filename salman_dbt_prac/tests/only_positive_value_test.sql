select
    *
from
    {{ref('bronze_sales')}}
where 
    gross_amount < 0  AND net_amount < 0
    {# {{source('source_schema','fact_sales')}} #}