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
exec xsp.dropone('view', 'consulta_rastro_proceso');
create view consulta_rastro_proceso as
select
    rastro_proceso.id_rastro_proceso,
    rastro_proceso.fecha_hora_inicio_ejecucion,
    rastro_proceso.fecha_hora_fin_ejecucion,
    rastro_proceso.id_usuario,
    rastro_proceso.codigo_usuario,
    rastro_proceso.nombre_usuario,
    rastro_proceso.id_funcion,
    rastro_proceso.codigo_funcion,
    rastro_proceso.nombre_funcion,
    rastro_proceso.pagina_funcion,
    rastro_proceso.id_clase_recurso_valor,
    rastro_proceso.recurso_valor,
    rastro_proceso.id_recurso,
    rastro_proceso.version_recurso,
    rastro_proceso.codigo_recurso,
    rastro_proceso.nombre_recurso,
    rastro_proceso.id_propietario_recurso,
    rastro_proceso.id_segmento_recurso,
    rastro_proceso.pagina_recurso,
    rastro_proceso.etiqueta_lenguaje,
    rastro_proceso.numero_condicion_eje_fun,
    rastro_proceso.nombre_archivo,
    rastro_proceso.descripcion_error,
    rastro_proceso.id_grupo_proceso,
    rastro_proceso.id_rastro_proceso_superior,
    rastro_proceso.numero_condicion_eje_tem,
    rastro_proceso.nombre_archivo_tem,
    rastro_proceso.descripcion_error_tem,
    rastro_proceso.ultima_transaccion,
    rastro_proceso.transacciones,
    rastro_proceso.subprocesos,
    rastro_proceso.subprocesos_pendientes,
    rastro_proceso.subprocesos_en_progreso,
    rastro_proceso.subprocesos_sin_errores,
    rastro_proceso.subprocesos_con_errores,
    rastro_proceso.subprocesos_cancelados,
    rastro_proceso.procedimiento_after_update,
        usuario_1.codigo_usuario as codigo_usuario_1,
        usuario_1.nombre_usuario as nombre_usuario_1,
        funcion_2.codigo_funcion as codigo_funcion_2,
        funcion_2.nombre_funcion as nombre_funcion_2,
        condicion_eje_fun_4.numero_condicion_eje_fun as numero_condicion_eje_fun_4,
        condicion_eje_fun_4.codigo_condicion_eje_fun as codigo_condicion_eje_fun_4,
        condicion_eje_fun_5.numero_condicion_eje_fun as numero_condicion_eje_fun_5,
        condicion_eje_fun_5.codigo_condicion_eje_fun as codigo_condicion_eje_fun_5
    from rastro_proceso
    left outer join usuario usuario_1 on usuario_1.id_usuario = rastro_proceso.id_usuario
    left outer join funcion funcion_2 on funcion_2.id_funcion = rastro_proceso.id_funcion
    inner join condicion_eje_fun condicion_eje_fun_4 on condicion_eje_fun_4.numero_condicion_eje_fun = rastro_proceso.numero_condicion_eje_fun
    inner join condicion_eje_fun condicion_eje_fun_5 on condicion_eje_fun_5.numero_condicion_eje_fun = rastro_proceso.numero_condicion_eje_tem
;
