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
exec xsp.dropone('view', 'consulta_vista_funcion_col');
create view consulta_vista_funcion_col as
select
    vista_funcion_col.id,
    vista_funcion_col.version,
    vista_funcion_col.nombre,
    vista_funcion_col.vista,
    vista_funcion_col.columna,
    vista_funcion_col.alias,
    vista_funcion_col.etiqueta,
    vista_funcion_col.secuencia,
    vista_funcion_col.agregacion,
    vista_funcion_col.grupo,
    vista_funcion_col.orden,
    vista_funcion_col.visible,
    vista_funcion_col.graficable,
    vista_funcion_col.pixeles,
    vista_funcion_col.ancho_por_mil,
        vista_funcion_1.codigo as codigo_1,
        vista_funcion_1.nombre as nombre_1,
        vista_funcion_1.propietario as propietario_1,
            usuario_1_2.codigo_usuario as codigo_usuario_1_2,
            usuario_1_2.nombre_usuario as nombre_usuario_1_2,
        funcion_parametro_2.codigo_funcion_parametro as codigo_funcion_parametro_2,
        funcion_parametro_2.nombre_funcion_parametro as nombre_funcion_parametro_2,
        tipo_agregacion_3.numero as numero_3,
        tipo_agregacion_3.codigo as codigo_3,
        tipo_agregacion_3.nombre as nombre_3,
        vista_funcion_col_4.nombre as nombre_4
    from vista_funcion_col
    inner join(vista_funcion vista_funcion_1
        inner join usuario usuario_1_2 on usuario_1_2.id_usuario = vista_funcion_1.propietario)
    on vista_funcion_1.id = vista_funcion_col.vista
    left outer join funcion_parametro funcion_parametro_2 on funcion_parametro_2.id_funcion_parametro = vista_funcion_col.columna
    left outer join tipo_agregacion tipo_agregacion_3 on tipo_agregacion_3.numero = vista_funcion_col.agregacion
    left outer join vista_funcion_col vista_funcion_col_4 on vista_funcion_col_4.id = vista_funcion_col.grupo
;
