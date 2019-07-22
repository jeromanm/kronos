CREATE OR REPLACE FORCE VIEW V_SELECCION_CON_OBJECION as  
  Select dp.nombre as departamento, dt.id as id_distrito, dt.codigo as codigo_distrito, dt.nombre as distrito, ba.nombre as barrio,
      cp.id as id_clase_pension, cp.nombre as clase_pension, pn.id as id_pension, ce.fecha_transicion,
      pe.codigo as cedula, pe.nombre as nombre, calcular_edad(pe.fecha_nacimiento) as edad,
      ep.codigo as estado_pension, nvl((Select ex.codigo From expediente_sime ex Where pn.numero_sime_entrada=ex.id),(Select ex.codigo From expediente_sime ex Where pn.numero_sime=ex.id)) as numero_sime,
      nvl(pn.numero_sime_entrada,pn.numero_sime) as idsime, pe.icv, pe.direccion, op.observaciones, op.comentarios, pn.estado as id_estado_pension,
      (Select valor_x1 From regla where variable_x1=901 And valor_x1<>0 And rownum=1) as valor_referencia_icv,
      case when instr(upper(op.observaciones),'PROVEEDOR')>0 And instr(upper(op.observaciones),', ARCHIVO')>0 then substr(op.observaciones,instr(upper(op.observaciones),'PROVEEDOR'),instr(upper(op.observaciones),', ARCHIVO')) else op.observaciones end as proveedor
From pension pn inner join persona pe on pn.persona = pe.id
    inner join departamento dp on pe.departamento = dp.id
    inner join distrito dt on pe.distrito = dt.id
    left outer join barrio ba on pe.barrio = ba.id
    inner join clase_pension cp on pn.clase= cp.id
    inner join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true'
    inner join estado_pension ep on pn.estado = ep.numero
    inner join censo_persona ce on pe.id = ce.persona;