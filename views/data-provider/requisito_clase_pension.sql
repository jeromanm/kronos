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
exec xsp.dropone('view', 'consulta_requ_clas_pensi_62371');
create view consulta_requ_clas_pensi_62371 as
select
    requisito_clase_pension.id,
    requisito_clase_pension.version,
    requisito_clase_pension.codigo,
    requisito_clase_pension.nombre,
    requisito_clase_pension.clase_pension,
    requisito_clase_pension.clase_requisito,
    requisito_clase_pension.tipo_requisito,
    requisito_clase_pension.obligatorio,
    requisito_clase_pension.renovable,
    requisito_clase_pension.cantidad_periodo_vigencia,
    requisito_clase_pension.unidad_periodo_vigencia,
    requisito_clase_pension.activo_requisito,
    requisito_clase_pension.indigena,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        clase_requisito_2.codigo as codigo_2,
        clase_requisito_2.nombre as nombre_2,
        tipo_requisito_3.numero as numero_3,
        tipo_requisito_3.codigo as codigo_3,
        unidad_periodo_vigencia_4.numero as numero_4,
        unidad_periodo_vigencia_4.codigo as codigo_4
    from requisito_clase_pension
    inner join clase_pension clase_pension_1 on clase_pension_1.id = requisito_clase_pension.clase_pension
    inner join clase_requisito clase_requisito_2 on clase_requisito_2.id = requisito_clase_pension.clase_requisito
    inner join tipo_requisito tipo_requisito_3 on tipo_requisito_3.numero = requisito_clase_pension.tipo_requisito
    left outer join unidad_periodo_vigencia unidad_periodo_vigencia_4 on unidad_periodo_vigencia_4.numero = requisito_clase_pension.unidad_periodo_vigencia
;
