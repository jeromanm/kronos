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
exec xsp.dropone('view', 'consulta_barrio');
create view consulta_barrio as
select
    barrio.id,
    barrio.version,
    barrio.codigo,
    barrio.nombre,
    barrio.distrito,
    barrio.tipo_area,
        distrito_1.codigo as codigo_1,
        distrito_1.nombre as nombre_1,
        tipo_area_2.numero as numero_2,
        tipo_area_2.codigo as codigo_2
    from barrio
    inner join distrito distrito_1 on distrito_1.id = barrio.distrito
    inner join tipo_area tipo_area_2 on tipo_area_2.numero = barrio.tipo_area
;
