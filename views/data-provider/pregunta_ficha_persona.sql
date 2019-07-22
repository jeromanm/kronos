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
exec xsp.dropone('view', 'consulta_preg_fich_perso_32227');
create view consulta_preg_fich_perso_32227 as
select
    pregunta_ficha_persona.id,
    pregunta_ficha_persona.version,
    pregunta_ficha_persona.clave,
    pregunta_ficha_persona.codigo,
    pregunta_ficha_persona.nombre,
    pregunta_ficha_persona.tipo_dato_pregunta,
    pregunta_ficha_persona.tipo_dato_respuesta,
    pregunta_ficha_persona.peso_rural,
    pregunta_ficha_persona.peso_urbano,
    pregunta_ficha_persona.funcion,
    pregunta_ficha_persona.fase,
    pregunta_ficha_persona.version_ficha,
    pregunta_ficha_persona.inactiva,
        tipo_dato_pregunta_1.numero as numero_1,
        tipo_dato_pregunta_1.codigo as codigo_1,
        tipo_dato_respuesta_2.numero as numero_2,
        tipo_dato_respuesta_2.codigo as codigo_2,
        funcion_ficha_persona_3.nombre as nombre_3
    from pregunta_ficha_persona
    inner join tipo_dato_pregunta tipo_dato_pregunta_1 on tipo_dato_pregunta_1.numero = pregunta_ficha_persona.tipo_dato_pregunta
    inner join tipo_dato_respuesta tipo_dato_respuesta_2 on tipo_dato_respuesta_2.numero = pregunta_ficha_persona.tipo_dato_respuesta
    left outer join funcion_ficha_persona funcion_ficha_persona_3 on funcion_ficha_persona_3.id = pregunta_ficha_persona.funcion
;
