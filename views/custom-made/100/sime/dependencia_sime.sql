create or replace view dependencia_sime as
select
d.id,
to_char(r.codigo)||'/'||to_char(d.codigo) as codigo,
r.nombre||'/'||d.nombre as nombre
from dependencia@sgemh d
inner join reparticion@sgemh r on d.reparticion_id = r.id;
/