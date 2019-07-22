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
exec xsp.dropone('view', 'consulta_rastro_informe');
create view consulta_rastro_informe as
select
    rastro_informe.id_rastro_informe,
    rastro_informe.fecha_hora_inicio_ejecucion,
    rastro_informe.fecha_hora_fin_ejecucion,
    rastro_informe.nombre_informe,
    rastro_informe.formato_informe,
    rastro_informe.limite_filas,
    rastro_informe.id_usuario,
    rastro_informe.codigo_usuario,
    rastro_informe.nombre_usuario,
    rastro_informe.id_funcion,
    rastro_informe.codigo_funcion,
    rastro_informe.nombre_funcion,
    rastro_informe.pagina_funcion,
    rastro_informe.id_clase_recurso_valor,
    rastro_informe.recurso_valor,
    rastro_informe.id_recurso,
    rastro_informe.version_recurso,
    rastro_informe.codigo_recurso,
    rastro_informe.nombre_recurso,
    rastro_informe.id_propietario_recurso,
    rastro_informe.id_segmento_recurso,
    rastro_informe.pagina_recurso,
    rastro_informe.instruccion_select,
    rastro_informe.select_restringido,
    rastro_informe.filas_seleccionadas,
    rastro_informe.etiqueta_lenguaje,
    rastro_informe.numero_condicion_eje_fun,
    rastro_informe.nombre_archivo,
    rastro_informe.descripcion_error,
        usuario_1.codigo_usuario as codigo_usuario_1,
        usuario_1.nombre_usuario as nombre_usuario_1,
        funcion_2.codigo_funcion as codigo_funcion_2,
        funcion_2.nombre_funcion as nombre_funcion_2,
        condicion_eje_fun_4.numero_condicion_eje_fun as numero_condicion_eje_fun_4,
        condicion_eje_fun_4.codigo_condicion_eje_fun as codigo_condicion_eje_fun_4
    from rastro_informe
    left outer join usuario usuario_1 on usuario_1.id_usuario = rastro_informe.id_usuario
    left outer join funcion funcion_2 on funcion_2.id_funcion = rastro_informe.id_funcion
    inner join condicion_eje_fun condicion_eje_fun_4 on condicion_eje_fun_4.numero_condicion_eje_fun = rastro_informe.numero_condicion_eje_fun
;
