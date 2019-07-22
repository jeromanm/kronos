  create or replace view v_resumen_clase_pension as
Select cp.codigo, cp.nombre,  rp.mes_resumen,  rp.ano_resumen, cp.id as id_clase_pension,
       cc.codigo codigo_asignado, cc.nombre nombre_asignado,
      sum(case when cc.tipo_concepto=1 then dp.monto else (dp.monto*-1) end) as total,
      count(distinct rp.id) cant_pension, pp.periodo,
      sum(case when cc.tipo_concepto=1 then dp.monto else 0 end) as asignacion,
      sum(case when cc.tipo_concepto=2 then dp.monto else 0 end) as deduccion
From planilla_pago pp inner join planilla_periodo_pago pr on pp.id=pr.planilla
  inner join clase_pension cp on pp.clase_pension = cp.id
  inner join pension pn on cp.id = pn.clase
  inner join resumen_pago_pension rp on pp.id = rp.planilla And pn.id=rp.pension And pr.mes = rp.mes_resumen And pr.ano = rp.ano_resumen
  inner join detalle_pago_pension dp on rp.id = dp.resumen
  inner join clase_concepto cc on dp.clase_concepto=cc.id
Where nvl(dp.activo,'true')<>'false'
Group By cp.codigo, cp.nombre,  rp.mes_resumen,  rp.ano_resumen, cp.id, cc.codigo, cc.nombre, pp.periodo;
/