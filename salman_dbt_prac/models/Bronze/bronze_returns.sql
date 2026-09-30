select 
    * 
from
    {{ source('source_schema', 'fact_returns') }}