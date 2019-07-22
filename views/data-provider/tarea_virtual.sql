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
exec xsp.dropone('view', 'consulta_tarea_virtual');
create view consulta_tarea_virtual as
select
    tarea_virtual.id,
    tarea_virtual.id_funcion,
    tarea_virtual.id_clase_recurso_valor,
    tarea_virtual.id_recurso_valor,
    tarea_virtual.codigo_recurso_valor,
    tarea_virtual.nombre_recurso_valor,
    tarea_virtual.id_propietario,
    tarea_virtual.id_segmento,
    tarea_virtual.lista_funciones
    from tarea_virtual
;
