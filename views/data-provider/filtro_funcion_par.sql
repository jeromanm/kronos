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
exec xsp.dropone('view', 'consulta_filtro_funcion_par');
create view consulta_filtro_funcion_par as
select
    filtro_funcion_par.id_filtro_funcion_par,
    filtro_funcion_par.version_filtro_funcion_par,
    filtro_funcion_par.id_filtro_funcion,
    filtro_funcion_par.id_funcion_parametro,
    filtro_funcion_par.numero_operador_com,
    filtro_funcion_par.valor,
    filtro_funcion_par.valor_fecha_hora,
    filtro_funcion_par.id_clase_recurso_valor,
    filtro_funcion_par.recurso_valor,
    filtro_funcion_par.id_recurso_valor,
    filtro_funcion_par.codigo_recurso_valor,
    filtro_funcion_par.nombre_recurso_valor,
    filtro_funcion_par.pagina_recurso,
        filtro_funcion_1.codigo_filtro_funcion as codigo_filtro_funcion_1,
        filtro_funcion_1.nombre_filtro_funcion as nombre_filtro_funcion_1,
        filtro_funcion_1.id_usuario as id_usuario_1,
            usuario_1_2.codigo_usuario as codigo_usuario_1_2,
            usuario_1_2.nombre_usuario as nombre_usuario_1_2,
        funcion_parametro_2.codigo_funcion_parametro as codigo_funcion_parametro_2,
        funcion_parametro_2.nombre_funcion_parametro as nombre_funcion_parametro_2,
        operador_com_3.numero_operador_com as numero_operador_com_3,
        operador_com_3.codigo_operador_com as codigo_operador_com_3
    from filtro_funcion_par
    inner join(filtro_funcion filtro_funcion_1
        inner join usuario usuario_1_2 on usuario_1_2.id_usuario = filtro_funcion_1.id_usuario)
    on filtro_funcion_1.id_filtro_funcion = filtro_funcion_par.id_filtro_funcion
    left outer join funcion_parametro funcion_parametro_2 on funcion_parametro_2.id_funcion_parametro = filtro_funcion_par.id_funcion_parametro
    inner join operador_com operador_com_3 on operador_com_3.numero_operador_com = filtro_funcion_par.numero_operador_com
;
