CREATE OR REPLACE FORCE VIEW V_DETALLE_PAGO_PENSION AS 
  Select mes, ano, monto, clase_pension, id_clase_pension, nombre_pension, nombre, id_clase_concepto, codigo_concepto,
        departamento, distrito, cedula, nombre_persona, numero_solicitud, periodo,
        tipo_concepto, pension, nvl(asignacion,0) asignacion, nvl(deduccion,0)  deduccion, id_numero_solicitud
  From (select cp.id as clase_pension,(select sum(nvl(dd.monto, 0))
                                    from detalle_pago_pension dd inner join clase_concepto cc on dd.clase_concepto = cc.id
                                      inner join tipo_concepto tc on cc.tipo_concepto = tc.numero
                                    where dd.resumen = rp.id
                                      and dd.id=d.id
                                      and tc.numero = 1) asignacion,
               (select sum(nvl(dd.monto, 0)) from detalle_pago_pension dd
                 inner join clase_concepto cc on dd.clase_concepto = cc.id
                 inner join tipo_concepto tc on cc.tipo_concepto = tc.numero
                 where dd.resumen = rp.id
                 and dd.id=d.id and tc.numero = 2) deduccion,
                d.mes_planilla mes, d.ano_planilla ano, d.monto monto,
              cp.id id_clase_pension,cp.nombre nombre_pension, pp.periodo,
              cc.nombre nombre,cc.codigo codigo_concepto, de.nombre departamento,di.nombre distrito,p.codigo cedula,p.nombre nombre_persona,
              cc.id as id_clase_concepto, cc.tipo_concepto tipo_concepto, rp.pension pension, op.numero_solicitud, ns.id as id_numero_solicitud
        from detalle_pago_pension d inner join resumen_pago_pension rp on d.resumen=rp.id
          inner join clase_concepto cc on d.clase_concepto=cc.id
          inner join planilla_pago pp on rp.planilla=pp.id
          inner join pension pen on pen.id=rp.pension
          inner join persona p on pen.persona=p.id
          inner join departamento de on de.id=p.departamento
          inner join distrito di on de.id=di.departamento
          inner join clase_pension cp on pp.clase_pension=cp.id
          left outer join detalle_orden_pago dp on rp.id = dp.resumen_pago_pension
          left outer join orden_pago op on dp.orden_pago = op.id
          left outer join numero_solicitud ns on op.numero_solicitud = ns.codigo
      where to_number(rp.mes_resumen)=d.mes_planilla
        and to_number(rp.ano_resumen)=d.ano_planilla
        and p.distrito=di.id And nvl(d.activo,'true')<>'false')
group by  mes, ano, monto, clase_pension, id_clase_pension,nombre_pension, nombre, codigo_concepto, numero_solicitud, id_numero_solicitud, periodo,
        departamento, distrito, cedula, nombre_persona, id_clase_concepto, tipo_concepto, pension, asignacion, deduccion;
/