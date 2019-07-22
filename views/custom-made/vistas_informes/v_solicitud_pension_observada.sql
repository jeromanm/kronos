  CREATE OR REPLACE FORCE VIEW V_SOLICITUD_PENSION_OBSERVADA as
Select dp.nombre as departamento, dp.id as id_departamento, dt.nombre as distrito, dt.id as id_distrito, ba.nombre as barrio, es.codigo as sime,
      sp.cedula as cedula, sp.nombre, calcular_edad(pe.fecha_nacimiento) as edad, pe.direccion, nvl(ec.codigo,'N/E') as estado_censo,
      nvl(ep.codigo,'N/E') as estado_pension, nvl(fp.miembro_hogar,'N/E') as miembro_hogar, 
      (Select op.objecion_invalida From objecion_pension op where pn.id = op.pension And rownum=1) as objecion_valida,
      sp.linea, sp.observaciones, pn.id as id_pension, pe.id as id_persona, concatenar_objecion(pn.id, 2, 'true') as observacion_objecion, 
      concatenar_objecion(pn.id, 1, 'true') as comentario_objecion, sp.fecha_transicion as fecha, es.id as idsime, sp.archivo
From solicitud_pension sp left outer join pension pn on sp.pension = pn.id
  left outer join persona pe on sp.persona = pe.id
  left outer join censo_persona cp on sp.censo_persona = cp.id
  left outer join ficha_persona fp on sp.ficha_persona = fp.id
  left outer join expediente_sime es on sp.numero_sime = es.id
  left outer join departamento dp on pe.departamento = dp.id
  left outer join distrito dt on pe.distrito = dt.id
  left outer join barrio ba on pe.barrio = ba.id
  left outer join estado_censo ec on cp.estado = ec.numero
  left outer join estado_pension ep on pn.estado = ep.numero;
/
