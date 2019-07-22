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
exec xsp.dropone('view', 'consulta_rastro_funcion_par');
create view consulta_rastro_funcion_par as
select
    rastro_funcion_par.id_rastro_funcion_par,
    rastro_funcion_par.id_rastro_funcion,
    rastro_funcion_par.id_parametro,
    rastro_funcion_par.codigo_parametro,
    rastro_funcion_par.nombre_parametro,
    rastro_funcion_par.valor_parametro,
    rastro_funcion_par.codigo_recurso_parametro,
    rastro_funcion_par.nombre_recurso_parametro,
    rastro_funcion_par.valor_aparente_parametro,
    rastro_funcion_par.valor_anterior,
    rastro_funcion_par.codigo_recurso_anterior,
    rastro_funcion_par.nombre_recurso_anterior,
    rastro_funcion_par.valor_aparente_anterior,
    rastro_funcion_par.diferente_valor,
    rastro_funcion_par.id_clase_recurso_valor,
    rastro_funcion_par.pagina_recurso,
        rastro_funcion_1.fecha_hora_ejecucion as fecha_hora_ejecucion_1,
        rastro_funcion_1.id_usuario as id_usuario_1,
        rastro_funcion_1.codigo_usuario as codigo_usuario_1,
        rastro_funcion_1.nombre_usuario as nombre_usuario_1,
        rastro_funcion_1.id_funcion as id_funcion_1,
        rastro_funcion_1.codigo_recurso as codigo_recurso_1,
        rastro_funcion_1.nombre_recurso as nombre_recurso_1,
            usuario_1_1.codigo_usuario as codigo_usuario_1_1,
            usuario_1_1.nombre_usuario as nombre_usuario_1_1,
            funcion_1_2.codigo_funcion as codigo_funcion_1_2,
            funcion_1_2.nombre_funcion as nombre_funcion_1_2,
            condicion_eje_fun_1_4.codigo_condicion_eje_fun as codigo_condicion_eje_fun_1_4,
        parametro_2.codigo_parametro as codigo_parametro_2,
        parametro_2.nombre_parametro as nombre_parametro_2
    from rastro_funcion_par
    inner join(rastro_funcion rastro_funcion_1
        left outer join usuario usuario_1_1 on usuario_1_1.id_usuario = rastro_funcion_1.id_usuario
        left outer join funcion funcion_1_2 on funcion_1_2.id_funcion = rastro_funcion_1.id_funcion
        inner join condicion_eje_fun condicion_eje_fun_1_4 on condicion_eje_fun_1_4.numero_condicion_eje_fun = rastro_funcion_1.numero_condicion_eje_fun)
    on rastro_funcion_1.id_rastro_funcion = rastro_funcion_par.id_rastro_funcion
    left outer join parametro parametro_2 on parametro_2.id_parametro = rastro_funcion_par.id_parametro
;
