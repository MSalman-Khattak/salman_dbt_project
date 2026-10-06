{% set incremental_load = true %}
{% set last_load = 3 %}

{% set columns = ["sales_id", "date_sk", "gross_amount"]%}

select 
    {% for col in columns %}
        {{col}}{{"," if not loop.last else ""}}
    {% endfor %}
from 
     {{ref('bronze_sales')}}

{% if incremental_load == true %}    
    where 
        date_sk > {{last_load}}
{% endif %}