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
exec xsp.dropone('view', 'consulta_rastro_funcion');
create view consulta_rastro_funcion as
select
    rastro_funcion.id_rastro_funcion,
    rastro_funcion.fecha_hora_ejecucion,
    rastro_funcion.id_usuario,
    rastro_funcion.codigo_usuario,
    rastro_funcion.nombre_usuario,
    rastro_funcion.id_funcion,
    rastro_funcion.codigo_funcion,
    rastro_funcion.nombre_funcion,
    rastro_funcion.pagina_funcion,
    rastro_funcion.id_clase_recurso_valor,
    rastro_funcion.recurso_valor,
    rastro_funcion.id_recurso,
    rastro_funcion.version_recurso,
    rastro_funcion.codigo_recurso,
    rastro_funcion.nombre_recurso,
    rastro_funcion.id_propietario_recurso,
    rastro_funcion.id_segmento_recurso,
    rastro_funcion.pagina_recurso,
    rastro_funcion.numero_condicion_eje_fun,
    rastro_funcion.descripcion_error,
        usuario_1.codigo_usuario as codigo_usuario_1,
        usuario_1.nombre_usuario as nombre_usuario_1,
        funcion_2.codigo_funcion as codigo_funcion_2,
        funcion_2.nombre_funcion as nombre_funcion_2,
        condicion_eje_fun_4.numero_condicion_eje_fun as numero_condicion_eje_fun_4,
        condicion_eje_fun_4.codigo_condicion_eje_fun as codigo_condicion_eje_fun_4
    from rastro_funcion
    left outer join usuario usuario_1 on usuario_1.id_usuario = rastro_funcion.id_usuario
    left outer join funcion funcion_2 on funcion_2.id_funcion = rastro_funcion.id_funcion
    inner join condicion_eje_fun condicion_eje_fun_4 on condicion_eje_fun_4.numero_condicion_eje_fun = rastro_funcion.numero_condicion_eje_fun
;
