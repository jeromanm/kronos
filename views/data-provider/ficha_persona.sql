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
exec xsp.dropone('view', 'consulta_ficha_persona');
create view consulta_ficha_persona as
select
    ficha_persona.id,
    ficha_persona.version,
    ficha_persona.codigo,
    ficha_persona.nombre,
    ficha_persona.ficha_hogar,
    ficha_persona.nombres,
    ficha_persona.apellidos,
    ficha_persona.edad,
    ficha_persona.sexo_persona,
    ficha_persona.tipo_persona_hogar,
    ficha_persona.miembro_hogar,
    ficha_persona.numero_orden_identificacion,
    ficha_persona.numero_cedula,
    ficha_persona.tipo_excepcion_cedula,
    ficha_persona.fecha_nacimiento,
    ficha_persona.numero_telefono,
    ficha_persona.estado_civil,
    ficha_persona.ocupacion,
    ficha_persona.rama,
    ficha_persona.observaciones,
    ficha_persona.version_ficha_hogar,
        ficha_hogar_1.codigo as codigo_1,
        sexo_persona_2.numero as numero_2,
        sexo_persona_2.codigo as codigo_2,
        tipo_persona_hogar_3.numero as numero_3,
        tipo_persona_hogar_3.codigo as codigo_3,
        tipo_excepcion_cedula_4.numero as numero_4,
        tipo_excepcion_cedula_4.codigo as codigo_4,
        estado_civil_5.numero as numero_5,
        estado_civil_5.codigo as codigo_5,
        ocupacion_6.codigo as codigo_6,
        ocupacion_6.nombre as nombre_6,
        rama_7.codigo as codigo_7,
        rama_7.nombre as nombre_7
    from ficha_persona
    left outer join ficha_hogar ficha_hogar_1 on ficha_hogar_1.id = ficha_persona.ficha_hogar
    left outer join sexo_persona sexo_persona_2 on sexo_persona_2.numero = ficha_persona.sexo_persona
    left outer join tipo_persona_hogar tipo_persona_hogar_3 on tipo_persona_hogar_3.numero = ficha_persona.tipo_persona_hogar
    left outer join tipo_excepcion_cedula tipo_excepcion_cedula_4 on tipo_excepcion_cedula_4.numero = ficha_persona.tipo_excepcion_cedula
    left outer join estado_civil estado_civil_5 on estado_civil_5.numero = ficha_persona.estado_civil
    left outer join ocupacion ocupacion_6 on ocupacion_6.id = ficha_persona.ocupacion
    left outer join rama rama_7 on rama_7.id = ficha_persona.rama
;
