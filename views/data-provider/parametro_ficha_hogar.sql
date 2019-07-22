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
exec xsp.dropone('view', 'consulta_parametro_ficha_hogar');
create view consulta_parametro_ficha_hogar as
select
    parametro_ficha_hogar.id,
    parametro_ficha_hogar.version,
    parametro_ficha_hogar.codigo,
    parametro_ficha_hogar.funcion,
    parametro_ficha_hogar.numero,
    parametro_ficha_hogar.nombre,
    parametro_ficha_hogar.descripcion,
    parametro_ficha_hogar.tipo_dato,
        funcion_ficha_hogar_1.nombre as nombre_1,
        tipo_dato_respuesta_2.numero as numero_2,
        tipo_dato_respuesta_2.codigo as codigo_2
    from parametro_ficha_hogar
    inner join funcion_ficha_hogar funcion_ficha_hogar_1 on funcion_ficha_hogar_1.id = parametro_ficha_hogar.funcion
    inner join tipo_dato_respuesta tipo_dato_respuesta_2 on tipo_dato_respuesta_2.numero = parametro_ficha_hogar.tipo_dato
;
