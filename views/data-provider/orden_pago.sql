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
exec xsp.dropone('view', 'consulta_orden_pago');
create view consulta_orden_pago as
select
    orden_pago.id,
    orden_pago.version,
    orden_pago.codigo,
    orden_pago.concepto_desde,
    orden_pago.mes,
    orden_pago.ano,
    orden_pago.numero_solicitud,
    orden_pago.tipo_presupuesto,
    orden_pago.estado,
    orden_pago.cuenta,
    orden_pago.fecha_transicion,
    orden_pago.usuario,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        estado_orden_pago_3.numero as numero_3,
        estado_orden_pago_3.codigo as codigo_3,
        usuario_4.codigo_usuario as codigo_usuario_4,
        usuario_4.nombre_usuario as nombre_usuario_4
    from orden_pago
    inner join clase_pension clase_pension_1 on clase_pension_1.id = orden_pago.concepto_desde
    left outer join estado_orden_pago estado_orden_pago_3 on estado_orden_pago_3.numero = orden_pago.estado
    left outer join usuario usuario_4 on usuario_4.id_usuario = orden_pago.usuario
;
