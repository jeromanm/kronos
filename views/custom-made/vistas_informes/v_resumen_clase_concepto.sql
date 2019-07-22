CREATE OR REPLACE FORCE VIEW V_RESUMEN_CLASE_CONCEPTO AS
Select pl.ano as annio, pl.mes, cp.nombre as clase_pension, cc.nombre as clase_concepto, dp.nombre as departamento, dt.nombre as distrito, 
      Count(distinct rp.id) as cant, sum(case cc.tipo_concepto when 1 then de.monto else de.monto*-1 end) as monto,
      cp.id as id_clase_pension, dp.id as id_departamento, dt.id as id_distrito
From detalle_pago_pension de inner join resumen_pago_pension rp on de.resumen=rp.id
  inner join clase_concepto cc on de.clase_concepto = cc.id
  inner join pension pn on rp.pension = pn.id
  inner join planilla_pago pp on pn.clase = pp.clase_pension
  inner join planilla_periodo_pago pl on pp.id = pl.planilla
  inner join clase_pension cp on pn.clase = cp.id
  inner join persona pe on pn.persona = pe.id
  inner join departamento dp on pe.departamento = dp.id
  inner join distrito dt on pe.distrito = dt.id
Group By pl.ano, pl.mes, cp.nombre, cc.nombre, dp.nombre, dt.nombre, cp.id, dp.id, dt.id;
/