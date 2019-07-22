create or replace view v_cancelar_cuenta as
select  calcular_edad(p.fecha_nacimiento) edad,
		s.cedula,
		p.nombre nombre_persona,
		(select b.nombre from barrio b where b.id=p.barrio )nombre_barrio,
		(select d.nombre from distrito d where d.id=p.distrito)nombre_distrito,
		v.valor nombre_director, g.valor nombre_adm_finan,
		s.fecha_solicitud fecha_solicitud,
		re.valor,
		(select nombre from banco where id=p.banco) banco
		--select r.pension from resumen_pago_pension r where pe.id=r.pension)esta_en_planilla
from persona p inner join pension pe on p.id=pe.persona 
	inner join variable_global v on v.numero = 107 
	inner join variable_global g on g.numero=110 
	inner join solicitud_cuenta s on p.codigo=s.cedula
	inner join variable_global re on re.numero=121
where p.cuenta_bancaria is not null
	and pe.activa='false'
	and pe.estado in (9,10)
	and fecha_respuesta is null;
/