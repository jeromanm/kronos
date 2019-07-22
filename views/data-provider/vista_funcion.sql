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
exec xsp.dropone('view', 'consulta_vista_funcion');
create view consulta_vista_funcion as
select
    vista_funcion.id,
    vista_funcion.version,
    vista_funcion.codigo,
    vista_funcion.nombre,
    vista_funcion.descripcion,
    vista_funcion.funcion,
    vista_funcion.propietario,
    vista_funcion.publica,
    vista_funcion.valida,
    vista_funcion.secuencia,
    vista_funcion.id_vista_funcion_original,
        funcion_1.codigo_funcion as codigo_funcion_1,
        funcion_1.nombre_funcion as nombre_funcion_1,
        usuario_2.codigo_usuario as codigo_usuario_2,
        usuario_2.nombre_usuario as nombre_usuario_2
    from vista_funcion
    left outer join funcion funcion_1 on funcion_1.id_funcion = vista_funcion.funcion
    inner join usuario usuario_2 on usuario_2.id_usuario = vista_funcion.propietario
;
