  CREATE OR REPLACE FORCE VIEW V_PERSONA_OBJECION AS 
  Select pen.id penid, o.comentarios, p.codigo ,p.nombre, calcular_edad(fecha_nacimiento) edad,
      (select di.nombre from distrito di where di.id=p.distrito) distrito,
      (select de.nombre from departamento de where de.id=p.departamento) departamento,
      (select ba.nombre from barrio ba where ba.id=p.barrio) barrio,
      ex.nro||'/'||ex.ano numero_sime,
      ex.id idsime, o.objecion_invalida objecion_invalida, p.icv icv,
      p.direccion, o.observaciones, cp.nombre as clase_pension
From objecion_pension o inner join  pension pen  on o.pension=pen.id
  inner join persona p on pen.persona=p.id 
  left outer join expediente@sgemh ex on (pen.numero_sime_entrada=ex.id or pen.numero_sime=ex.id)
  inner join clase_pension cp on pen.clase= cp.id
where o.objecion_invalida='true';
/