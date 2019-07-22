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
exec xsp.dropone('view', 'consulta_rol_funcion_par');
create view consulta_rol_funcion_par as
select
    rol_funcion_par.id_rol_funcion_par,
    rol_funcion_par.version_rol_funcion_par,
    rol_funcion_par.id_rol_funcion,
    rol_funcion_par.id_funcion_parametro,
        funcion_parametro_2.codigo_funcion_parametro as codigo_funcion_parametro_2,
        funcion_parametro_2.nombre_funcion_parametro as nombre_funcion_parametro_2
    from rol_funcion_par
    left outer join funcion_parametro funcion_parametro_2 on funcion_parametro_2.id_funcion_parametro = rol_funcion_par.id_funcion_parametro
;
