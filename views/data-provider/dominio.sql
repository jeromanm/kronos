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
exec xsp.dropone('view', 'consulta_dominio');
create view consulta_dominio as
select
    dominio.id_dominio,
    dominio.version_dominio,
    dominio.codigo_dominio,
    dominio.nombre_dominio,
    dominio.descripcion_dominio,
    dominio.nombre_tabla,
    dominio.numero_tipo_dominio,
    dominio.id_clase_recurso,
    dominio.id_funcion_seleccion,
    dominio.id_dominio_segmento,
        tipo_dominio_1.numero_tipo_dominio as numero_tipo_dominio_1,
        tipo_dominio_1.codigo_tipo_dominio as codigo_tipo_dominio_1,
        clase_recurso_2.codigo_clase_recurso as codigo_clase_recurso_2,
        clase_recurso_2.nombre_clase_recurso as nombre_clase_recurso_2,
        funcion_3.codigo_funcion as codigo_funcion_3,
        funcion_3.nombre_funcion as nombre_funcion_3,
        dominio_4.codigo_dominio as codigo_dominio_4,
        dominio_4.nombre_dominio as nombre_dominio_4
    from dominio
    inner join tipo_dominio tipo_dominio_1 on tipo_dominio_1.numero_tipo_dominio = dominio.numero_tipo_dominio
    inner join clase_recurso clase_recurso_2 on clase_recurso_2.id_clase_recurso = dominio.id_clase_recurso
    left outer join funcion funcion_3 on funcion_3.id_funcion = dominio.id_funcion_seleccion
    left outer join dominio dominio_4 on dominio_4.id_dominio = dominio.id_dominio_segmento
;
