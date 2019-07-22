CREATE OR REPLACE FORCE VIEW V_VISTA_AREA_SIME  AS 
select  c.id, c.numero_sime, p.codigo as C_I_N, c.nombre_recurrente NOMBRE, c.fecha_recepcion FECHA_RECEPCION, 
        p.nombre NOMBRE_BENEFICIARIO, CASE  WHEN mov.tipomovimiento = 7 THEN rep_mov.codigo || '-' || dep_mov.codigo || ' ' || dep_mov.nombre 
        WHEN act.activo = 1 THEN rep_act.codigo || '-' || dep_act.codigo || ' ' || dep_act.nombre 
        WHEN sal.activo = 1 THEN rep_sal.codigo || '-' || dep_sal.codigo || ' ' || dep_sal.nombre END DEPENDENCIA, 
        CASE  WHEN mov.tipomovimiento = 7 THEN mov.fecha WHEN act.activo = 1 THEN act.fechainicio WHEN sal.activo = 1 THEN sal.fechainicio END FECHA_DEPENDENCIA,  
        CASE  WHEN mov.tipomovimiento = 7 THEN trunc(sysdate - mov.fecha) WHEN act.activo = 1 THEN trunc(sysdate - act.fechainicio) WHEN sal.activo = 1 THEN trunc(sysdate - sal.fechainicio) END DIAS_DEPENDENCIA,
        CASE  WHEN act.activo = 1 THEN  'ACTIVO' WHEN sal.activo = 1 THEN  'ENVIO' WHEN mov.tipomovimiento = 7 THEN 'ARCHIVADO'
        WHEN mov.tipomovimiento =  0 THEN 'RECEPCION' WHEN mov.tipomovimiento = 2 THEN 'RECHAZO' WHEN mov.tipomovimiento = 3 THEN 'ANULACION'
        WHEN mov.tipomovimiento = 4 THEN 'ACEPTACION' WHEN mov.tipomovimiento = 5 THEN 'NINGUNO' WHEN mov.tipomovimiento = 6 THEN 'MOVIMIENTO' END  EXPEDIENTE_ESTADO,
        pn.id as id_pension, c.dependencia AREA, cp.nombre as clase_pension, ex.nro || '/' || ex.ano as sime, to_char(ex.fechacreacion,'dd/mm/yyyy') as fecha_sime, 
        trunc(sysdate - ex.fechacreacion) as dia_expediente, c.estado_consulta estado, trunc(sysdate - c.fecha_recepcion) as dias_reclamo, 
        case when cp.codigo = '01' then 'V' when cp.codigo = '02' then 'HV' when cp.codigo = '03' then 'PG' when cp.codigo = '04' then 'HVHD'
        when cp.codigo = '05' then 'HVHS' when cp.codigo = '06' then 'HVHM' when cp.codigo = '07' then 'HPP' when cp.codigo = '08' then 'HCP'
        when cp.codigo = '09' then 'HHMP' when cp.codigo = '10' then 'HPM' when cp.codigo = '11' then 'HCM' when cp.codigo = '12' then 'HHMM'
        when cp.codigo = '13' then 'AM' when cp.codigo = '14' then 'GS' when cp.codigo = '15' then 'IVM' when cp.codigo = '16' then 'OJ'
        when cp.codigo = '17' then 'SV' when cp.codigo = '18' then 'DCJ' else to_char(upper(substr(gp.descripcion,1,3))) end as tipo_pension
From consulta_ciudadano c inner join  persona p on p.id=c.persona 
  left outer join pension pn on p.id = pn.persona And c.pension = pn.id
  left outer join clase_pension cp on pn.clase = cp.id
  left outer join cedula ce on c.cedula_recurrente = ce.id
  left outer join sgemh.expediente@sgemh ex on c.numero_sime = ex.id
  left outer join sgemh.englose@sgemh gl on ex.id = gl.englosado_id
  left outer join sgemh.movimiento@sgemh mov on nvl(gl.principal_id,ex.id) = mov.expediente_id
  left outer join sgemh.activo@sgemh act on nvl(gl.principal_id,ex.id) = act.expediente_id and act.activo = 1 
  left outer join sgemh.salida@sgemh sal on nvl(gl.principal_id,ex.id) = sal.expediente_id and sal.activo = 1
  left outer join sgemh.dependencia@sgemh dep_mov on mov.dependenciaactual_id = dep_mov.id
  left outer join sgemh.reparticion@sgemh rep_mov on dep_mov.reparticion_id = rep_mov.id
  left outer join sgemh.dependencia@sgemh dep_act on act.dependenciaactivo_id = dep_act.id
  left outer join sgemh.reparticion@sgemh rep_act on dep_act.reparticion_id = rep_act.id
  left outer join sgemh.dependencia@sgemh dep_sal on sal.dependenciasalida_id = dep_sal.id
  left outer join sgemh.reparticion@sgemh rep_sal on dep_sal.reparticion_id = rep_sal.id
  left outer join grupo_pension gp on cp.grupo = gp.id
where (ex.id is null 
OR ( act.activo = 1 OR sal.activo = 1) and (mov.id = (select max(mv.id) from sgemh.movimiento@sgemh mv where mv.expediente_id = nvl(gl.principal_id,ex.id))))
order by p.codigo;
