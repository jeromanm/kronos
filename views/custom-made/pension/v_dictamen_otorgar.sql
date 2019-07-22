create or replace view v_dictamen_otorgar as 
 select numero_sime, cedula, nombre_beneficiario, clase_pension , fecha_dictamen_otorgar, dictamen_otorgar,estado_pension, pension,
departamento, distrito, edad, resolucion_otorgar, fecha_resolucion_otorgar,nombre_director, nrosime
from
(select ex.nro||'/'||ex.ano numero_sime, pe.codigo cedula, pe.nombre
nombre_beneficiario,  cp.nombre clase_pension, p.fecha_dictamen_otorgar fecha_dictamen_otorgar, p.dictamen_otorgar dictamen_otorgar,
ep.codigo estado_pension,p.id pension,
(select de.nombre from departamento de where de.id=pe.departamento) departamento,
(select di.nombre from distrito di where di.id=pe.distrito) distrito,
(select valor from variable_global where numero=107)nombre_director,ex.id nrosime,
p.resolucion_otorgar resolucion_otorgar, p.fecha_resolucion_otorgar fecha_resolucion_otorgar,
calcular_edad(pe.fecha_nacimiento) edad
from pension p inner join persona pe on
pe.id=p.persona inner join clase_pension cp on cp.id=p.clase
inner join estado_pension ep on
p.estado=ep.numero inner join expediente@sgemh ex on p.numero_sime=ex.id
where dictamen_otorgar is not null
and p.estado=7
and cp.codigo=13)b
where pension in (select lp.pension from lote_pension lp inner join lote l
on lp.lote=l.id)
order by 3;
/