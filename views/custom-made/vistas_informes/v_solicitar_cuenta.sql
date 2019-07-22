create or replace view v_solicitar_cuenta as
Select a.codigo as nro_solicitud, to_char(a.fecha_solicitud,'dd/mm/yyyy') as fecha_solicitud, a.EDAD_DESDE, a.EDAD_HASTA,
      (Select vg.valor From variable_global vg Where vg.numero=107) as nombre_director, (Select vg.valor From variable_global vg Where vg.numero=110) as nombre_finanza,
      d.nombre as clase_pension_desde, e.nombre as CLASE_PENSION_HASTA, a.FECHA_RESPUESTA, f.codigo as estado,  
      c.codigo as cedula, c.nombre, calcular_edad(c.fecha_nacimiento) as edad
From encabezado_solicitud a inner join solicitud_cuenta b on a.codigo = b.nro_solicitud
  inner join persona c on b.cedula = c.codigo
  left outer join clase_pension d on a.CLASE_PENSION_DESDE = d.id
  left outer join clase_pension e on a.CLASE_PENSION_HASTA = e.id
  inner join estado_solicitud f on a.estado_solicitud = f.numero;
  /