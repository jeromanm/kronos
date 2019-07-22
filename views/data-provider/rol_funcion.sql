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
exec xsp.dropone('view', 'consulta_rol_funcion');
create view consulta_rol_funcion as
select
    rol_funcion.id_rol_funcion,
    rol_funcion.version_rol_funcion,
    rol_funcion.id_rol,
    rol_funcion.id_funcion,
    rol_funcion.id_conjunto_segmento,
    rol_funcion.es_acceso_personalizado,
    rol_funcion.es_tarea,
        rol_1.codigo_rol as codigo_rol_1,
        rol_1.nombre_rol as nombre_rol_1,
        funcion_2.codigo_funcion as codigo_funcion_2,
        funcion_2.nombre_funcion as nombre_funcion_2,
        conjunto_segmento_3.codigo_conjunto_segmento as codigo_conjunto_segmento_3,
        conjunto_segmento_3.nombre_conjunto_segmento as nombre_conjunto_segmento_3
    from rol_funcion
    inner join rol rol_1 on rol_1.id_rol = rol_funcion.id_rol
    left outer join funcion funcion_2 on funcion_2.id_funcion = rol_funcion.id_funcion
    left outer join conjunto_segmento conjunto_segmento_3 on conjunto_segmento_3.id_conjunto_segmento = rol_funcion.id_conjunto_segmento
;
