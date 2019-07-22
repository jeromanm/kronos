create or replace view v_bloqueo_cuenta as
select  calcular_edad(p.fecha_nacimiento )edad,
p.codigo cedula,
p.nombre nombre_persona,
(select b.nombre from barrio b where b.id=p.barrio )nombre_barrio,
(select d.nombre from distrito d where d.id=p.distrito)nombre_distrito,
v.valor nombre_director, g.valor nombre_adm_finan,
(select nombre from banco b where b.id=p.banco) banco,
(select max(op.fecha_transicion) from objecion_pension op inner join  pension p on op.pension=p.id
where  op.pension=p.id
and op.objecion_invalida='false'
and rownum=1
) fecha_objecion 
--select r.pension from resumen_pago_pension r where pe.id=r.pension)esta_en_planilla
from persona p inner join pension pe
on p.id=pe.persona inner join variable_global v on
v.numero = 107 inner join variable_global g on
g.numero=110 
where p.cuenta_bancaria is not null
and pe.activa='true'
and pe.estado not in (9,10);
/