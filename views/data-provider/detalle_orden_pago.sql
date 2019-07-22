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
exec xsp.dropone('view', 'consulta_detalle_orden_pago');
create view consulta_detalle_orden_pago as
select
    detalle_orden_pago.id,
    detalle_orden_pago.version,
    detalle_orden_pago.codigo,
    detalle_orden_pago.orden_pago,
    detalle_orden_pago.resumen_pago_pension,
    detalle_orden_pago.orden,
    detalle_orden_pago.pec_secuen,
    detalle_orden_pago.pension,
    detalle_orden_pago.persona,
        orden_pago_1.codigo as codigo_1,
        resumen_pago_pension_2.codigo as codigo_2,
        resumen_pago_pension_2.nombre as nombre_2,
        pension_3.codigo as codigo_3,
        persona_4.codigo as codigo_4,
        persona_4.nombre as nombre_4
    from detalle_orden_pago
    inner join orden_pago orden_pago_1 on orden_pago_1.id = detalle_orden_pago.orden_pago
    left outer join resumen_pago_pension resumen_pago_pension_2 on resumen_pago_pension_2.id = detalle_orden_pago.resumen_pago_pension
    inner join pension pension_3 on pension_3.id = detalle_orden_pago.pension
    inner join persona persona_4 on persona_4.id = detalle_orden_pago.persona
;
