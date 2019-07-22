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
exec xsp.dropone('view', 'consulta_filtro_funcion');
create view consulta_filtro_funcion as
select
    filtro_funcion.id_filtro_funcion,
    filtro_funcion.version_filtro_funcion,
    filtro_funcion.codigo_filtro_funcion,
    filtro_funcion.nombre_filtro_funcion,
    filtro_funcion.descripcion_filtro_funcion,
    filtro_funcion.id_funcion,
    filtro_funcion.id_usuario,
    filtro_funcion.es_publico,
    filtro_funcion.id_filtro_funcion_original,
        funcion_1.codigo_funcion as codigo_funcion_1,
        funcion_1.nombre_funcion as nombre_funcion_1,
        usuario_2.codigo_usuario as codigo_usuario_2,
        usuario_2.nombre_usuario as nombre_usuario_2
    from filtro_funcion
    left outer join funcion funcion_1 on funcion_1.id_funcion = filtro_funcion.id_funcion
    inner join usuario usuario_2 on usuario_2.id_usuario = filtro_funcion.id_usuario
;
