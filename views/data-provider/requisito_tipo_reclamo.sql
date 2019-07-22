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
exec xsp.dropone('view', 'consulta_requi_tipo_recl_82270');
create view consulta_requi_tipo_recl_82270 as
select
    requisito_tipo_reclamo.id,
    requisito_tipo_reclamo.version,
    requisito_tipo_reclamo.codigo,
    requisito_tipo_reclamo.nombre,
    requisito_tipo_reclamo.tipo_reclamo,
    requisito_tipo_reclamo.clase_requisito,
    requisito_tipo_reclamo.tipo_requisito,
    requisito_tipo_reclamo.obligatorio,
    requisito_tipo_reclamo.renovable,
    requisito_tipo_reclamo.cantidad_periodo_vigencia,
    requisito_tipo_reclamo.unidad_periodo_vigencia,
        tipo_reclamo_1.numero as numero_1,
        tipo_reclamo_1.codigo as codigo_1,
        clase_requisito_2.codigo as codigo_2,
        clase_requisito_2.nombre as nombre_2,
        tipo_requisito_3.numero as numero_3,
        tipo_requisito_3.codigo as codigo_3,
        unidad_periodo_vigencia_4.numero as numero_4,
        unidad_periodo_vigencia_4.codigo as codigo_4
    from requisito_tipo_reclamo
    inner join tipo_reclamo tipo_reclamo_1 on tipo_reclamo_1.numero = requisito_tipo_reclamo.tipo_reclamo
    inner join clase_requisito clase_requisito_2 on clase_requisito_2.id = requisito_tipo_reclamo.clase_requisito
    inner join tipo_requisito tipo_requisito_3 on tipo_requisito_3.numero = requisito_tipo_reclamo.tipo_requisito
    left outer join unidad_periodo_vigencia unidad_periodo_vigencia_4 on unidad_periodo_vigencia_4.numero = requisito_tipo_reclamo.unidad_periodo_vigencia
;
