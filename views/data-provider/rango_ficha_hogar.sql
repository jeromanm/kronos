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
exec xsp.dropone('view', 'consulta_rango_ficha_hogar');
create view consulta_rango_ficha_hogar as
select
    rango_ficha_hogar.id,
    rango_ficha_hogar.version,
    rango_ficha_hogar.pregunta,
    rango_ficha_hogar.numeral,
    rango_ficha_hogar.expresion,
    rango_ficha_hogar.valor,
    rango_ficha_hogar.peso_rural,
    rango_ficha_hogar.peso_urbano,
        pregunta_ficha_hogar_1.clave as clave_1,
        pregunta_ficha_hogar_1.nombre as nombre_1
    from rango_ficha_hogar
    inner join pregunta_ficha_hogar pregunta_ficha_hogar_1 on pregunta_ficha_hogar_1.id = rango_ficha_hogar.pregunta
;
