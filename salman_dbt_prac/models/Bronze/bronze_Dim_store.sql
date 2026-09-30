select 
    *
from
    {{ source('source_schema', 'dim_store') }}