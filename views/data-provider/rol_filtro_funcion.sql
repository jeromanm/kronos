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
exec xsp.dropone('view', 'consulta_rol_filtro_funcion');
create view consulta_rol_filtro_funcion as
select
    rol_filtro_funcion.id_rol_filtro_funcion,
    rol_filtro_funcion.version_rol_filtro_funcion,
    rol_filtro_funcion.id_rol,
    rol_filtro_funcion.id_filtro_funcion,
        rol_1.codigo_rol as codigo_rol_1,
        rol_1.nombre_rol as nombre_rol_1,
        filtro_funcion_2.codigo_filtro_funcion as codigo_filtro_funcion_2,
        filtro_funcion_2.nombre_filtro_funcion as nombre_filtro_funcion_2
    from rol_filtro_funcion
    inner join rol rol_1 on rol_1.id_rol = rol_filtro_funcion.id_rol
    inner join filtro_funcion filtro_funcion_2 on filtro_funcion_2.id_filtro_funcion = rol_filtro_funcion.id_filtro_funcion
;
