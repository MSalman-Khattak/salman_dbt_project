select 
    *
from
    {{ source('source_schema', 'dim_date') }}