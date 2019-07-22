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
exec xsp.dropone('view', 'consulta_respuesta_ficha_hogar');
create view consulta_respuesta_ficha_hogar as
select
    respuesta_ficha_hogar.id,
    respuesta_ficha_hogar.version,
    respuesta_ficha_hogar.ficha,
    respuesta_ficha_hogar.pregunta,
    respuesta_ficha_hogar.rango,
    respuesta_ficha_hogar.texto,
    respuesta_ficha_hogar.numero,
    respuesta_ficha_hogar.fecha,
        ficha_hogar_1.codigo as codigo_1,
        pregunta_ficha_hogar_2.clave as clave_2,
        pregunta_ficha_hogar_2.nombre as nombre_2,
        rango_ficha_hogar_3.expresion as expresion_3
    from respuesta_ficha_hogar
    inner join ficha_hogar ficha_hogar_1 on ficha_hogar_1.id = respuesta_ficha_hogar.ficha
    inner join pregunta_ficha_hogar pregunta_ficha_hogar_2 on pregunta_ficha_hogar_2.id = respuesta_ficha_hogar.pregunta
    left outer join rango_ficha_hogar rango_ficha_hogar_3 on rango_ficha_hogar_3.id = respuesta_ficha_hogar.rango
;
