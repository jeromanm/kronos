create or replace view v_resolucion_denegar as
select cp.nombre clase_pension, p.nombre nombre_persona,
 p.codigo cedula, pn.fecha_resolucion_denegar fecha_resolucion_denegar,e.nro ||'/'||e.ano sime,
(select valor from variable_global where numero=107)nombre_director,
(select codigo from variable_global where numero=107)cargo,
(select valor from variable_global where numero=108)nombre_sg,
(select codigo from variable_global where numero=108)cargo_sg,
pn.resolucion_denegar, pn.resumen_resolucion_denegar,
pn.dictamen_denegar
from pension pn, clase_pension cp, persona p, expediente@sgemh e
where pn.clase=cp.id
and pn.persona=p.id
and pn.numero_sime=e.id;
/