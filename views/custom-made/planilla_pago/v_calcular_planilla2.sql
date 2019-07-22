create or replace view v_calcular_planilla2 as
select pp.planilla,
       pp.mes mes_pla,
       pp.ano ano_pla,
       to_char(last_day(to_date(f.desde)), 'mm') mes_d,
       to_char(last_day(to_date(f.desde)), 'yyyy') ano_d,
       to_char(last_day(to_date(f.hasta)), 'mm') mes_h,
       to_char(last_day(to_date(f.hasta)), 'yyyy') ano_h,
       pp.codigo,
       f.codigo codigo_concepto,
       p.cedula ||','|| p.nombres ||' '||p.apellidos  nombres,
       d.id pension,
       (select c.nombre from clase_pension c where c.id = a.clase_pension) nombre_pension,
       p.id id_persona,
       p.cedula cedula_persona,
       p.cuenta_bancaria,
       e.id id_clase_concepto,
       e.nombre clase_concepto_desc,
       b.id id_concepto_planilla_pago,
       0 monto_concepto_planilla_pago,
       0 jornales_concepto_plani_pago,
       0 porcentaje_concepto_plani_pago,
       case
         when nvl(f.monto, 0) = 0 then
          nvl(b.monto,0)
         else
          nvl(f.monto, 0)
       end monto_concepto_pension,
       case
         when nvl(f.porcentaje, 0) = 0 then
          nvl(b.porcentaje,0)
         else
          nvl(f.porcentaje, 0)
       end pocentaje_concepto_pension,
       case
         when nvl(f.jornales, 0) = 0 then
          nvl(b.jornales,0)
         else
          nvl(f.jornales, 0)
       end jornales_concepto_pension,
       h.numero tipo_concepto,
       f.desde,
       f.hasta,
       nvl(f.saldo_inicial, 0) saldo_inicial,
       nvl(f.saldo_actual, 0) saldo_actual,
       nvl(f.monto_acumulado, 0) monto_acumulado,
       nvl(f.limite, 0) limite,
       nvl(f.monto,0) monto,
       f.bloqueado,
       f.cancelado,
       i.numero numero_met_conc,
       i.codigo codigo_met_conc,
       i.requiere_monto requiere_monto_met_conc,
       i.requiere_jornales requiere_jornales_met_conc,
       i.requiere_porcentaje requiere_porcentaje_met_conc,
       f.limite limites,
       p.cuenta_bancaria cuentas
 from  planilla_pago          a,
       planilla_periodo_pago pp,
       concepto_planilla_pago b,
       pension                d,
       clase_concepto         e,
       concepto_pension       f,
       persona                p,
       tipo_concepto          h,
       metodo_concepto        i
 where a.id=pp.planilla
   and a.id = b.planilla
   and e.id = b.clase_concepto
   and d.id= f.pension
   and b.id = f.clase
   and d.persona = p.id
   and h.numero = e.tipo_concepto
   and i.numero = b.metodo
   and d.estado = 7
   and f.monto> 0
   and d.activa = 'true';
/