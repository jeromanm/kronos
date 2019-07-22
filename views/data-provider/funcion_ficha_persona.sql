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
exec xsp.dropone('view', 'consulta_funcion_ficha_persona');
create view consulta_funcion_ficha_persona as
select
    funcion_ficha_persona.id,
    funcion_ficha_persona.version,
    funcion_ficha_persona.nombre,
    funcion_ficha_persona.descripcion,
    funcion_ficha_persona.algoritmo,
    funcion_ficha_persona.tipo_dato,
        tipo_dato_respuesta_1.numero as numero_1,
        tipo_dato_respuesta_1.codigo as codigo_1
    from funcion_ficha_persona
    inner join tipo_dato_respuesta tipo_dato_respuesta_1 on tipo_dato_respuesta_1.numero = funcion_ficha_persona.tipo_dato
;
