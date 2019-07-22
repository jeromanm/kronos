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
exec xsp.dropone('view', 'consulta_funcion_parametro');
create view consulta_funcion_parametro as
select
    funcion_parametro.id_funcion_parametro,
    funcion_parametro.version_funcion_parametro,
    funcion_parametro.codigo_funcion_parametro,
    funcion_parametro.nombre_funcion_parametro,
    funcion_parametro.alias_funcion_parametro,
    funcion_parametro.columna_funcion_parametro,
    funcion_parametro.detalle_funcion_parametro,
    funcion_parametro.descripcion_funcion_parametro,
    funcion_parametro.numero_tipo_dato_par,
    funcion_parametro.id_lista_valor,
    funcion_parametro.id_clase_objeto_valor,
    funcion_parametro.valor_minimo,
    funcion_parametro.valor_maximo,
    funcion_parametro.valor_omision,
    funcion_parametro.criterio_busqueda,
    funcion_parametro.acceso_restringido,
    funcion_parametro.es_parametro_sin_rastro,
    funcion_parametro.es_parametro_segmento,
    funcion_parametro.es_parametro_heredado,
    funcion_parametro.es_parametro_vinculado,
    funcion_parametro.indice,
    funcion_parametro.id_funcion,
    funcion_parametro.id_parametro,
    funcion_parametro.numero_tipo_parametro,
    funcion_parametro.numero_tipo_comparacion,
    funcion_parametro.numero_tipo_valor,
    funcion_parametro.numero_rango_comparacion,
    funcion_parametro.id_funcion_referencia,
    funcion_parametro.id_clase_recurso_valor,
        tipo_dato_par_1.numero_tipo_dato_par as numero_tipo_dato_par_1,
        tipo_dato_par_1.codigo_tipo_dato_par as codigo_tipo_dato_par_1,
        funcion_2.codigo_funcion as codigo_funcion_2,
        funcion_2.nombre_funcion as nombre_funcion_2,
        parametro_3.codigo_parametro as codigo_parametro_3,
        parametro_3.nombre_parametro as nombre_parametro_3,
        tipo_parametro_4.numero_tipo_parametro as numero_tipo_parametro_4,
        tipo_parametro_4.codigo_tipo_parametro as codigo_tipo_parametro_4,
        tipo_comparacion_5.numero_tipo_comparacion as numero_tipo_comparacion_5,
        tipo_comparacion_5.codigo_tipo_comparacion as codigo_tipo_comparacion_5,
        tipo_valor_6.numero_tipo_valor as numero_tipo_valor_6,
        tipo_valor_6.codigo_tipo_valor as codigo_tipo_valor_6,
        rango_comparacion_7.numero_rango_comparacion as numero_rango_comparacion_7,
        rango_comparacion_7.codigo_rango_comparacion as codigo_rango_comparacion_7,
        funcion_8.codigo_funcion as codigo_funcion_8,
        funcion_8.nombre_funcion as nombre_funcion_8,
        clase_recurso_9.codigo_clase_recurso as codigo_clase_recurso_9,
        clase_recurso_9.nombre_clase_recurso as nombre_clase_recurso_9
    from funcion_parametro
    inner join tipo_dato_par tipo_dato_par_1 on tipo_dato_par_1.numero_tipo_dato_par = funcion_parametro.numero_tipo_dato_par
    inner join funcion funcion_2 on funcion_2.id_funcion = funcion_parametro.id_funcion
    inner join parametro parametro_3 on parametro_3.id_parametro = funcion_parametro.id_parametro
    inner join tipo_parametro tipo_parametro_4 on tipo_parametro_4.numero_tipo_parametro = funcion_parametro.numero_tipo_parametro
    left outer join tipo_comparacion tipo_comparacion_5 on tipo_comparacion_5.numero_tipo_comparacion = funcion_parametro.numero_tipo_comparacion
    inner join tipo_valor tipo_valor_6 on tipo_valor_6.numero_tipo_valor = funcion_parametro.numero_tipo_valor
    inner join rango_comparacion rango_comparacion_7 on rango_comparacion_7.numero_rango_comparacion = funcion_parametro.numero_rango_comparacion
    left outer join funcion funcion_8 on funcion_8.id_funcion = funcion_parametro.id_funcion_referencia
    left outer join clase_recurso clase_recurso_9 on clase_recurso_9.id_clase_recurso = funcion_parametro.id_clase_recurso_valor
;
