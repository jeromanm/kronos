CREATE OR REPLACE VIEW V_SIME_DEPENDENCIA AS
SELECT r.codigo || '-' || d.codigo codigo
     , d.nombre
     , nvl(a.fechafin, a.fechainicio) fecha
     , round((sysdate)-nvl(a.fechafin, a.fechainicio))cant_dias
   FROM activo@sgemh a, dependencia@sgemh d, reparticion@sgemh r
      WHERE a.activo = 1
      AND a.dependenciaactivo_id = d.id
      AND d.reparticion_id = r.id;


