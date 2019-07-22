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
exec xsp.dropone('view', 'consulta_segmento_area');
create view consulta_segmento_area as
select
    segmento_area.id,
    segmento_area.version,
    segmento_area.codigo,
    segmento_area.reparticion,
    segmento_area.dependencia,
    segmento_area.nombre,
    segmento_area.estado_area,
        estado_area_1.numero as numero_1,
        estado_area_1.codigo as codigo_1
    from segmento_area
    inner join estado_area estado_area_1 on estado_area_1.numero = segmento_area.estado_area
;
