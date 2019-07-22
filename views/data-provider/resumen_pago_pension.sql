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
exec xsp.dropone('view', 'consulta_resumen_pago_pension');
create view consulta_resumen_pago_pension as
select
    resumen_pago_pension.id,
    resumen_pago_pension.version,
    resumen_pago_pension.codigo,
    resumen_pago_pension.nombre,
    resumen_pago_pension.pension,
    resumen_pago_pension.nombre_pension,
    resumen_pago_pension.planilla,
    resumen_pago_pension.detalle_orden_pago,
    resumen_pago_pension.mes_resumen,
    resumen_pago_pension.ano_resumen,
    resumen_pago_pension.monto,
    resumen_pago_pension.cuenta_bancaria,
    resumen_pago_pension.orden,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        planilla_pago_2.codigo as codigo_2,
        planilla_pago_2.nombre as nombre_2,
        detalle_orden_pago_3.codigo as codigo_3
    from resumen_pago_pension
    inner join(pension pension_1
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = resumen_pago_pension.pension
    inner join planilla_pago planilla_pago_2 on planilla_pago_2.id = resumen_pago_pension.planilla
    left outer join detalle_orden_pago detalle_orden_pago_3 on detalle_orden_pago_3.id = resumen_pago_pension.detalle_orden_pago
;
