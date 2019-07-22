CREATE OR REPLACE FORCE VIEW V_CONCEPTO_OBLIGACION as 
  Select a.id, j.numero as estado_orden, c.id as id_clase_pension, c.codigo as codigo_clase_pension, c.nombre, a.mes, a.ano, a.numero_solicitud, 
        a.cuenta, nvl(i.nombre,'SIN CUENTA BANCARIA') as banco,
        count(b.id) as cantidad, min(b.orden) as desde, max(b.orden) as hasta,
        f.id as id_clase_concepto, f.codigo as codigo_clase_concepto, f.nombre as clase_concepto, sum(case f.tipo_concepto when 1 then e.monto else 0 end) as asignado,
        sum(case f.tipo_concepto when 2 then e.monto else 0 end) as deduccion
From orden_pago a inner join detalle_orden_pago b on a.id = b.orden_pago
  inner join clase_pension c on a.concepto_desde = c.id
  inner join resumen_pago_pension d on b.resumen_pago_pension = d.id
  inner join detalle_pago_pension e on d.id = e.resumen
  inner join clase_concepto f on e.clase_concepto = f.id
  inner join pension g on d.pension = g.id
  inner join persona h on g.persona = h.id
  left outer join banco i on h.banco = i.id
  inner join estado_orden_pago j on a.estado = j.numero
Group By a.id, c.id, c.codigo, c.nombre, a.mes, a.ano, a.numero_solicitud, a.cuenta, f.id, f.codigo, f.nombre, i.nombre, j.numero;
/