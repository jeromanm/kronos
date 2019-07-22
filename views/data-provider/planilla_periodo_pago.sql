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
exec xsp.dropone('view', 'consulta_planilla_periodo_pago');
create view consulta_planilla_periodo_pago as
select
    planilla_periodo_pago.id,
    planilla_periodo_pago.version,
    planilla_periodo_pago.codigo,
    planilla_periodo_pago.planilla,
    planilla_periodo_pago.mes,
    planilla_periodo_pago.ano,
    planilla_periodo_pago.estado,
    planilla_periodo_pago.abrir_siguiente,
    planilla_periodo_pago.comentarios,
        planilla_pago_1.codigo as codigo_1,
        planilla_pago_1.nombre as nombre_1,
        estado_periodo_pago_2.numero as numero_2,
        estado_periodo_pago_2.codigo as codigo_2
    from planilla_periodo_pago
    inner join planilla_pago planilla_pago_1 on planilla_pago_1.id = planilla_periodo_pago.planilla
    inner join estado_periodo_pago estado_periodo_pago_2 on estado_periodo_pago_2.numero = planilla_periodo_pago.estado
;
