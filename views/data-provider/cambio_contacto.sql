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
exec xsp.dropone('view', 'consulta_cambio_contacto');
create view consulta_cambio_contacto as
select
    cambio_contacto.id,
    cambio_contacto.version,
    cambio_contacto.persona,
    cambio_contacto.codigo,
    cambio_contacto.departamento_inicial,
    cambio_contacto.distrito_inicial,
    cambio_contacto.direccion,
    cambio_contacto.departamento,
    cambio_contacto.distrito,
    cambio_contacto.tipo_area,
    cambio_contacto.barrio,
    cambio_contacto.telefono_linea_baja,
    cambio_contacto.telefono_celular,
    cambio_contacto.estado,
    cambio_contacto.fecha_transicion,
    cambio_contacto.usuario_transicion,
    cambio_contacto.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        departamento_2.codigo as codigo_2,
        departamento_2.nombre as nombre_2,
        distrito_3.codigo as codigo_3,
        distrito_3.nombre as nombre_3,
        departamento_4.codigo as codigo_4,
        departamento_4.nombre as nombre_4,
        distrito_5.codigo as codigo_5,
        distrito_5.nombre as nombre_5,
        tipo_area_6.numero as numero_6,
        tipo_area_6.codigo as codigo_6,
        barrio_7.codigo as codigo_7,
        barrio_7.nombre as nombre_7,
        estado_cambio_contacto_8.numero as numero_8,
        estado_cambio_contacto_8.codigo as codigo_8,
        usuario_9.codigo_usuario as codigo_usuario_9,
        usuario_9.nombre_usuario as nombre_usuario_9
    from cambio_contacto
    inner join persona persona_1 on persona_1.id = cambio_contacto.persona
    inner join departamento departamento_2 on departamento_2.id = cambio_contacto.departamento_inicial
    inner join distrito distrito_3 on distrito_3.id = cambio_contacto.distrito_inicial
    inner join departamento departamento_4 on departamento_4.id = cambio_contacto.departamento
    inner join distrito distrito_5 on distrito_5.id = cambio_contacto.distrito
    left outer join tipo_area tipo_area_6 on tipo_area_6.numero = cambio_contacto.tipo_area
    left outer join barrio barrio_7 on barrio_7.id = cambio_contacto.barrio
    inner join estado_cambio_contacto estado_cambio_contacto_8 on estado_cambio_contacto_8.numero = cambio_contacto.estado
    inner join usuario usuario_9 on usuario_9.id_usuario = cambio_contacto.usuario_transicion
;
