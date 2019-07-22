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
exec xsp.dropone('view', 'consulta_variable_global');
create view consulta_variable_global as
select
    variable_global.numero,
    variable_global.version,
    variable_global.codigo,
    variable_global.tipo_dato,
    variable_global.valor,
    variable_global.valor_logico,
    variable_global.valor_numerico,
    variable_global.valor_fecha,
    variable_global.segmento_area,
        tipo_dato_variable_global_1.numero as numero_1,
        tipo_dato_variable_global_1.codigo as codigo_1,
        segmento_area_2.codigo as codigo_2
    from variable_global
    inner join tipo_dato_variable_global tipo_dato_variable_global_1 on tipo_dato_variable_global_1.numero = variable_global.tipo_dato
    left outer join segmento_area segmento_area_2 on segmento_area_2.id = variable_global.segmento_area
;
