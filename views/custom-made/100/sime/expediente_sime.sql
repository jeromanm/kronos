-- nro/ano es una clave única cuando original_id is null
create or replace view expediente_sime as
select
e.id,
nro||'/'||ano as codigo, nro as numero, ano as ary,
case when (observaciones is null) then '*** SIN REFERENCIA ***' else nombre||'-'||observaciones end as referencia
from expediente@sgemh e, persona@sgemh p
where e.original_id is null
and e.remitente_id=p.id;
/