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
exec xsp.dropone('view', 'consulta_conce_plan_pago_62217');
create view consulta_conce_plan_pago_62217 as
select
    concepto_planilla_pago.id,
    concepto_planilla_pago.version,
    concepto_planilla_pago.codigo,
    concepto_planilla_pago.nombre,
    concepto_planilla_pago.planilla,
    concepto_planilla_pago.clase_concepto,
    concepto_planilla_pago.metodo,
    concepto_planilla_pago.general,
    concepto_planilla_pago.monto,
    concepto_planilla_pago.jornales,
    concepto_planilla_pago.porcentaje,
    concepto_planilla_pago.bloqueado,
    concepto_planilla_pago.comentarios,
        planilla_pago_1.codigo as codigo_1,
        planilla_pago_1.nombre as nombre_1,
        clase_concepto_2.codigo as codigo_2,
        clase_concepto_2.nombre as nombre_2,
        metodo_concepto_3.numero as numero_3,
        metodo_concepto_3.codigo as codigo_3
    from concepto_planilla_pago
    inner join planilla_pago planilla_pago_1 on planilla_pago_1.id = concepto_planilla_pago.planilla
    inner join clase_concepto clase_concepto_2 on clase_concepto_2.id = concepto_planilla_pago.clase_concepto
    inner join metodo_concepto metodo_concepto_3 on metodo_concepto_3.numero = concepto_planilla_pago.metodo
;
