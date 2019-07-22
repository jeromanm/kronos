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
exec xsp.dropone('view', 'consulta_conjunto_segmento');
create view consulta_conjunto_segmento as
select
    conjunto_segmento.id_conjunto_segmento,
    conjunto_segmento.version_conjunto_segmento,
    conjunto_segmento.codigo_conjunto_segmento,
    conjunto_segmento.nombre_conjunto_segmento,
    conjunto_segmento.descripcion_conjunto_segmento,
    conjunto_segmento.id_clase_recurso,
    conjunto_segmento.id_usuario_supervisor,
    conjunto_segmento.nombre_clase_fabricador,
    conjunto_segmento.es_conjunto_especial,
        clase_recurso_1.codigo_clase_recurso as codigo_clase_recurso_1,
        clase_recurso_1.nombre_clase_recurso as nombre_clase_recurso_1,
        usuario_2.codigo_usuario as codigo_usuario_2,
        usuario_2.nombre_usuario as nombre_usuario_2
    from conjunto_segmento
    left outer join clase_recurso clase_recurso_1 on clase_recurso_1.id_clase_recurso = conjunto_segmento.id_clase_recurso
    left outer join usuario usuario_2 on usuario_2.id_usuario = conjunto_segmento.id_usuario_supervisor
;
