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
exec xsp.dropone('view', 'consulta_resp_fich_perso_32345');
create view consulta_resp_fich_perso_32345 as
select
    respuesta_ficha_persona.id,
    respuesta_ficha_persona.version,
    respuesta_ficha_persona.ficha,
    respuesta_ficha_persona.pregunta,
    respuesta_ficha_persona.rango,
    respuesta_ficha_persona.texto,
    respuesta_ficha_persona.numero,
    respuesta_ficha_persona.fecha,
        ficha_persona_1.codigo as codigo_1,
        ficha_persona_1.nombre as nombre_1,
        pregunta_ficha_persona_2.clave as clave_2,
        pregunta_ficha_persona_2.nombre as nombre_2,
        rango_ficha_persona_3.expresion as expresion_3
    from respuesta_ficha_persona
    inner join ficha_persona ficha_persona_1 on ficha_persona_1.id = respuesta_ficha_persona.ficha
    inner join pregunta_ficha_persona pregunta_ficha_persona_2 on pregunta_ficha_persona_2.id = respuesta_ficha_persona.pregunta
    left outer join rango_ficha_persona rango_ficha_persona_3 on rango_ficha_persona_3.id = respuesta_ficha_persona.rango
;
