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
exec xsp.dropone('view', 'consulta_funcion');
create view consulta_funcion as
select
    funcion.id_funcion,
    funcion.version_funcion,
    funcion.codigo_funcion,
    funcion.nombre_funcion,
    funcion.nombre_java,
    funcion.nombre_sql,
    funcion.descripcion_funcion,
    funcion.clausula_where,
    funcion.clausula_order,
    funcion.es_publica,
    funcion.es_programatica,
    funcion.es_protegida,
    funcion.es_personalizable,
    funcion.es_segmentable,
    funcion.es_supervisable,
    funcion.es_heredada,
    funcion.numero_tipo_funcion,
    funcion.numero_tipo_rastro_fun,
    funcion.id_dominio,
    funcion.id_grupo_proceso,
        tipo_funcion_1.numero_tipo_funcion as numero_tipo_funcion_1,
        tipo_funcion_1.codigo_tipo_funcion as codigo_tipo_funcion_1,
        tipo_rastro_fun_2.numero_tipo_rastro_fun as numero_tipo_rastro_fun_2,
        tipo_rastro_fun_2.codigo_tipo_rastro_fun as codigo_tipo_rastro_fun_2,
        dominio_3.codigo_dominio as codigo_dominio_3,
        dominio_3.nombre_dominio as nombre_dominio_3,
        grupo_proceso_4.codigo_grupo_proceso as codigo_grupo_proceso_4,
        grupo_proceso_4.nombre_grupo_proceso as nombre_grupo_proceso_4
    from funcion
    inner join tipo_funcion tipo_funcion_1 on tipo_funcion_1.numero_tipo_funcion = funcion.numero_tipo_funcion
    inner join tipo_rastro_fun tipo_rastro_fun_2 on tipo_rastro_fun_2.numero_tipo_rastro_fun = funcion.numero_tipo_rastro_fun
    inner join dominio dominio_3 on dominio_3.id_dominio = funcion.id_dominio
    left outer join grupo_proceso grupo_proceso_4 on grupo_proceso_4.id_grupo_proceso = funcion.id_grupo_proceso
;
