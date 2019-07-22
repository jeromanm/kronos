create or replace view v_calcular_planilla as
select pp.planilla,
       pp.mes,
       pp.ano,
       a.codigo,
       pp.codigo codigo_pp,
       p.cedula ||','|| p.nombres ||' '||p.apellidos  nombres,
       d.id pension,
       c.nombre nombre_pension,
       p.id id_persona,
       p.cedula cedula_persona,
       p.cuenta_bancaria,
       e.id id_clase_concepto,
       e.nombre clase_concepto_desc,
       b.id id_concepto_planilla_pago,
       nvl(b.monto, 0) monto_concepto_planilla_pago,
       nvl(b.jornales, 0) jornales_concepto_plani_pago,
       nvl(b.porcentaje, 0) porcentaje_concepto_plani_pago,
       0 monto_concepto_pension,
       0 porcentaje_concepto_pension,
       0 jornales_concepto_pension,
       h.numero tipo_concepto,
       null desde,
       null hasta,
       0 saldo_inicial,
       0 saldo_actual,
       0 monto_acumulado,
       0 limite,
       0 monto,
       null bloqueado,
       null cancelado,
       i.numero numero_met_conc,
       i.codigo codigo_met_conc,
       i.requiere_monto requiere_monto_met_conc,
       i.requiere_jornales requiere_jornales_met_conc,
       i.requiere_porcentaje requiere_porcentaje_met_conc
  from planilla_pago          a,
       planilla_periodo_pago  pp,
       concepto_planilla_pago b,
       clase_pension          c,
       pension                d,
       persona                p,
       clase_concepto         e,
       tipo_concepto          h,
       metodo_concepto        i
 where a.id = pp.planilla
   and a.id =b.planilla
   and c.id = a.clase_pension
   and d.clase = c.id
   and d.persona = p.id
   and e.id = b.clase_concepto
   and h.numero = e.tipo_concepto
   and i.numero = b.metodo
   and d.estado = 7
   and d.activa = 'true'
   and b.monto>0;
/