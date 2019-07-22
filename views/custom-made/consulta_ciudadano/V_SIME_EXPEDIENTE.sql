CREATE OR REPLACE VIEW V_SIME_EXPEDIENTE AS
SELECT NULL codigo_dep_rep
     , 0 dependencia
     , NULL nombre_dep
     , NULL fecha_activo
     , NULL cant_dias_activo
     , NULL expediente_id
     , NULL nro_sime
     , NULL estado_activo
     , 0 cant_dias_sime
     , 0 cant_sime
     , NULL fecha_fin
     , 0 cant_sime_dias
     , null codigo_destino
     , null nombre_destino
     , null tipomovimiento
     , e.id
     , e.fechacreacion
     , te.nombre
     , t.ci
     , t.nombre nombre_persona
     , e.observaciones
FROM expediente@sgemh e INNER JOIN  persona@sgemh t
ON  e.remitente_id = t.id
INNER JOIN tipoexpediente@sgemh te
ON e.tipoexpediente_id = te.id
UNION
SELECT r.codigo || '/' || d.codigo  codigo_dep_rep
     ,d.id dependencia
     ,d.nombre nombre_dep
     , nvl(a.fechafin, a.fechainicio)  fecha_activo
     , round((sysdate)-nvl(a.fechafin, a.fechainicio)) cant_dias_activo
     , a.expediente_id expediente_id
     , e.nro || '/' || e.ano nro_sime
     , decode(e.activo, 1, 'ACTIVO', 0, 'INACTIVO') estado_activo
     , (trunc(sysdate)-trunc(e.fechacreacion)) cant_dias_sime
     , count(c.numero_sime) cant_sime
     , max(en.fechafin)fecha_fin
     , round(min(en.fechainicio)-max(s.fechafin))*-1 cant_sime_dias
     , null codigo_destino
     , null nombre_destino
     , null tipomovimiento
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
   FROM activo@sgemh a INNER JOIN dependencia@sgemh d ON d.id=a.dependenciaactivo_id
   INNER JOIN reparticion@sgemh r ON r.id = d.reparticion_id INNER JOIN  expediente@sgemh e
   ON e.id= a.expediente_id inner join  consulta_ciudadano c on e.id=c.numero_sime INNER JOIN  entrada@sgemh  en ON
   e.id = en.expediente_id INNER JOIN  salida@sgemh s ON
   e.id=s.expediente_id
      WHERE a.activo = 1
  GROUP BY  r.codigo || '/' || d.codigo,d.id
     ,d.nombre
     , nvl(a.fechafin, a.fechainicio)
     , round((sysdate)-nvl(a.fechafin, a.fechainicio))
     , a.expediente_id
     , e.nro || '/' || e.ano, e.activo,e.fechacreacion
UNION
SELECT r.codigo || '/' || d.codigo  codigo_dep_rep
     ,d.id dependencia
     ,d.nombre nombre_dep
     , nvl(a.fechafin, a.fechainicio)  fecha_activo
     , round((sysdate)-nvl(a.fechafin, a.fechainicio)) cant_dias_activo
     , a.expediente_id expediente_id
     , e.nro || '/' || e.ano nro_sime
     , decode(e.activo, 1, 'ACTIVO', 0, 'INACTIVO') estado_activo
     , (trunc(sysdate)-trunc(e.fechacreacion)) cant_dias_sime
     , null--count(c.numero_sime) cant_sime
     , max(en.fechafin)fecha_fin
     , round(min(en.fechainicio)-max(s.fechafin))*-1 cant_sime_dias
     , null codigo_destino
     , null nombre_destino
     , null tipomovimiento
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
   FROM activo@sgemh a INNER JOIN  dependencia@sgemh d ON d.id=a.dependenciaactivo_id
   INNER JOIN reparticion@sgemh r ON  r.id=d.reparticion_id
   INNER JOIN expediente@sgemh e on e.id=a.expediente_id
   INNER JOIN entrada@sgemh en ON e.id = en.expediente_id
   INNER JOIN salida@sgemh s ON e.id = s.expediente_id
   WHERE a.activo = 1
  GROUP BY  r.codigo || '/' || d.codigo
    ,d.id
     ,d.nombre
     , nvl(a.fechafin, a.fechainicio)
     , round((sysdate)-nvl(a.fechafin, a.fechainicio))
     , a.expediente_id
     , e.nro || '/' || e.ano
     , decode(e.activo, 1, 'ACTIVO', 0, 'INACTIVO')
     ,  (trunc(sysdate)-trunc(e.fechacreacion))
 UNION
    SELECT  null  codigo_dep_rep
     , null dependencia
     , null nombre_dep
     , null  fecha_activo
     , null cant_dias_activo
     , 0
     , null nro_sime
     , null estado_activo
     , 0 cant_dias_sime
     , 0
     , null
     , 0 cant_dias_sime
     , r.codigo || '-' || d.codigo codigo_destino
     , d.nombre nombre_destino
     , decode (m.tipomovimiento, 0, 'RECEPCION', 1,'ENVIO', 2, 'RECHAZO', 3 , 'ANULACION', 4, 'ACEPTACION', 5, 'NINGUNO' , 6, 'MOVIMIENTO', 7, 'ARCHIVADO')tipomovimiento
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
    FROM salida@sgemh s INNER JOIN  dependencia@sgemh d ON d.id=s.destino_id
    INNER JOIN reparticion@sgemh r ON r.id=d.reparticion_id
    INNER JOIN movimiento@sgemh m ON s.id=m.salida_id
    order by 2 asc;

