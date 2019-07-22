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
exec xsp.dropone('view', 'consulta_censo_persona');
create view consulta_censo_persona as
select
    censo_persona.id,
    censo_persona.version,
    censo_persona.codigo,
    censo_persona.persona,
    censo_persona.fecha,
    censo_persona.ficha,
    censo_persona.icv,
    censo_persona.tipo_pobreza,
    censo_persona.comentarios,
    censo_persona.departamento,
    censo_persona.distrito,
    censo_persona.tipo_area,
    censo_persona.barrio,
    censo_persona.direccion,
    censo_persona.numero_telefono,
    censo_persona.nombre_referente,
    censo_persona.numero_telefono_referente,
    censo_persona.numero_sime,
    censo_persona.archivo,
    censo_persona.linea,
    censo_persona.estado,
    censo_persona.fecha_transicion,
    censo_persona.usuario_transicion,
    censo_persona.observaciones,
    censo_persona.censista_externo,
    censo_persona.censista_interno,
    censo_persona.causa_anulacion,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.apellidos as apellidos_1,
        persona_1.nombres as nombres_1,
        persona_1.fecha_nacimiento as fecha_nacimiento_1,
        persona_1.referencia as referencia_1,
        persona_1.nombre_referente as nombre_referente_1,
        persona_1.telefono_referente as telefono_referente_1,
        persona_1.apodo as apodo_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        ficha_persona_2.codigo as codigo_2,
        ficha_persona_2.nombre as nombre_2,
        tipo_pobreza_3.numero as numero_3,
        tipo_pobreza_3.codigo as codigo_3,
        departamento_4.codigo as codigo_4,
        departamento_4.nombre as nombre_4,
        distrito_5.codigo as codigo_5,
        distrito_5.nombre as nombre_5,
        tipo_area_6.numero as numero_6,
        tipo_area_6.codigo as codigo_6,
        barrio_7.codigo as codigo_7,
        barrio_7.nombre as nombre_7,
        carga_archivo_9.codigo as codigo_9,
        estado_censo_10.numero as numero_10,
        estado_censo_10.codigo as codigo_10,
        usuario_11.codigo_usuario as codigo_usuario_11,
        usuario_11.nombre_usuario as nombre_usuario_11,
        censista_12.codigo as codigo_12,
        censista_12.nombre as nombre_12,
        usuario_13.codigo_usuario as codigo_usuario_13,
        usuario_13.nombre_usuario as nombre_usuario_13,
        causa_anulacion_censo_14.numero as numero_14,
        causa_anulacion_censo_14.codigo as codigo_14
    from censo_persona
    inner join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = censo_persona.persona
    left outer join ficha_persona ficha_persona_2 on ficha_persona_2.id = censo_persona.ficha
    left outer join tipo_pobreza tipo_pobreza_3 on tipo_pobreza_3.numero = censo_persona.tipo_pobreza
    left outer join departamento departamento_4 on departamento_4.id = censo_persona.departamento
    left outer join distrito distrito_5 on distrito_5.id = censo_persona.distrito
    left outer join tipo_area tipo_area_6 on tipo_area_6.numero = censo_persona.tipo_area
    left outer join barrio barrio_7 on barrio_7.id = censo_persona.barrio
    left outer join carga_archivo carga_archivo_9 on carga_archivo_9.id = censo_persona.archivo
    inner join estado_censo estado_censo_10 on estado_censo_10.numero = censo_persona.estado
    left outer join usuario usuario_11 on usuario_11.id_usuario = censo_persona.usuario_transicion
    left outer join censista censista_12 on censista_12.id = censo_persona.censista_externo
    left outer join usuario usuario_13 on usuario_13.id_usuario = censo_persona.censista_interno
    left outer join causa_anulacion_censo causa_anulacion_censo_14 on causa_anulacion_censo_14.numero = censo_persona.causa_anulacion
;
