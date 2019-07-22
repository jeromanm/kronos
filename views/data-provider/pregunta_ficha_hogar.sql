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
exec xsp.dropone('view', 'consulta_pregunta_ficha_hogar');
create view consulta_pregunta_ficha_hogar as
select
    pregunta_ficha_hogar.id,
    pregunta_ficha_hogar.version,
    pregunta_ficha_hogar.clave,
    pregunta_ficha_hogar.codigo,
    pregunta_ficha_hogar.nombre,
    pregunta_ficha_hogar.tipo_dato_pregunta,
    pregunta_ficha_hogar.tipo_dato_respuesta,
    pregunta_ficha_hogar.peso_rural,
    pregunta_ficha_hogar.peso_urbano,
    pregunta_ficha_hogar.funcion,
    pregunta_ficha_hogar.fase,
    pregunta_ficha_hogar.version_ficha,
    pregunta_ficha_hogar.inactiva,
        tipo_dato_pregunta_1.numero as numero_1,
        tipo_dato_pregunta_1.codigo as codigo_1,
        tipo_dato_respuesta_2.numero as numero_2,
        tipo_dato_respuesta_2.codigo as codigo_2,
        funcion_ficha_hogar_3.nombre as nombre_3
    from pregunta_ficha_hogar
    inner join tipo_dato_pregunta tipo_dato_pregunta_1 on tipo_dato_pregunta_1.numero = pregunta_ficha_hogar.tipo_dato_pregunta
    inner join tipo_dato_respuesta tipo_dato_respuesta_2 on tipo_dato_respuesta_2.numero = pregunta_ficha_hogar.tipo_dato_respuesta
    left outer join funcion_ficha_hogar funcion_ficha_hogar_3 on funcion_ficha_hogar_3.id = pregunta_ficha_hogar.funcion
;
