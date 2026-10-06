with deduplication_CTE as (
select 
    *,
    row_number() over (partition by Id order by updated desc) as dedplication_row_number
from 
    {{ source('source_schema', 'Items') }}
)

select 
    Id, Name, category, updated
from 
    deduplication_CTE
where 
    dedplication_row_number = 1
