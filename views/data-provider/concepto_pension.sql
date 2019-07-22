/*
 * Este programa es software libre; usted puede redistribuirlo y/o modificarlo bajo los terminos
 * de la licencia "GNU General Public License" publicada por la Fundacion "Free Software Foundation".
 * Este programa se distribuye con la esperanza de que pueda ser util, pero SIN NINGUNA GARANTIA;
 * vea la licencia "GNU General Public License" para obtener mas informacion.
 */
/*
 * author: ADALID
 * template: templates/jee1/oracle/views/create-data-provider-view.sql.vm
 * template-author: Jorge Campins
 */
exec xsp.dropone('view', 'consulta_concepto_pension');
create view consulta_concepto_pension as
select
    concepto_pension.id,
    concepto_pension.version,
    concepto_pension.codigo,
    concepto_pension.pension,
    concepto_pension.clase,
    concepto_pension.monto,
    concepto_pension.jornales,
    concepto_pension.porcentaje,
    concepto_pension.saldo_inicial,
    concepto_pension.saldo_actual,
    concepto_pension.monto_acumulado,
    concepto_pension.desde,
    concepto_pension.hasta,
    concepto_pension.limite,
    concepto_pension.cuenta,
    concepto_pension.bloqueado,
    concepto_pension.cancelado,
    concepto_pension.acuerdo_pago,
    concepto_pension.cant_recurrente,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        concepto_planilla_pago_2.codigo as codigo_2,
        concepto_planilla_pago_2.nombre as nombre_2,
        acuerdo_pago_3.codigo as codigo_3
    from concepto_pension
    inner join(pension pension_1
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = concepto_pension.pension
    inner join concepto_planilla_pago concepto_planilla_pago_2 on concepto_planilla_pago_2.id = concepto_pension.clase
    left outer join acuerdo_pago acuerdo_pago_3 on acuerdo_pago_3.id = concepto_pension.acuerdo_pago
;
