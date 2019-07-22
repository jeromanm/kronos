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
exec xsp.dropone('view', 'consulta_planilla_pago');
create view consulta_planilla_pago as
select
    planilla_pago.id,
    planilla_pago.version,
    planilla_pago.codigo,
    planilla_pago.nombre,
    planilla_pago.clase_pension,
    planilla_pago.periodo,
    planilla_pago.comentarios,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        periodo_planilla_pago_2.numero as numero_2,
        periodo_planilla_pago_2.codigo as codigo_2
    from planilla_pago
    inner join clase_pension clase_pension_1 on clase_pension_1.id = planilla_pago.clase_pension
    inner join periodo_planilla_pago periodo_planilla_pago_2 on periodo_planilla_pago_2.numero = planilla_pago.periodo
;
