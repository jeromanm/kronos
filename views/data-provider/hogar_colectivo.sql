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
exec xsp.dropone('view', 'consulta_hogar_colectivo');
create view consulta_hogar_colectivo as
select
    hogar_colectivo.id,
    hogar_colectivo.version,
    hogar_colectivo.codigo,
    hogar_colectivo.nombre,
    hogar_colectivo.departamento,
    hogar_colectivo.distrito,
    hogar_colectivo.tipo_area,
    hogar_colectivo.barrio,
    hogar_colectivo.direccion,
    hogar_colectivo.gps,
    hogar_colectivo.orden,
    hogar_colectivo.coordenada_x,
    hogar_colectivo.coordenada_y,
    hogar_colectivo.url_google_maps,
    hogar_colectivo.resolucion,
    hogar_colectivo.organizacion,
    hogar_colectivo.recibe_subsidio,
    hogar_colectivo.subsidio_gobernacion,
    hogar_colectivo.subsidio_municipalidad,
    hogar_colectivo.apellidos,
    hogar_colectivo.nombres,
    hogar_colectivo.cedula,
        departamento_1.codigo as codigo_1,
        departamento_1.nombre as nombre_1,
        distrito_2.codigo as codigo_2,
        distrito_2.nombre as nombre_2,
        tipo_area_3.numero as numero_3,
        tipo_area_3.codigo as codigo_3,
        barrio_4.codigo as codigo_4,
        barrio_4.nombre as nombre_4
    from hogar_colectivo
    inner join departamento departamento_1 on departamento_1.id = hogar_colectivo.departamento
    inner join distrito distrito_2 on distrito_2.id = hogar_colectivo.distrito
    inner join tipo_area tipo_area_3 on tipo_area_3.numero = hogar_colectivo.tipo_area
    left outer join barrio barrio_4 on barrio_4.id = hogar_colectivo.barrio
;
