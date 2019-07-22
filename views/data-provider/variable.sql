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
exec xsp.dropone('view', 'consulta_variable');
create view consulta_variable as
select
    variable.numero,
    variable.codigo,
    variable.tipo_dato,
        tipo_dato_variable_1.numero as numero_1,
        tipo_dato_variable_1.codigo as codigo_1
    from variable
    inner join tipo_dato_variable tipo_dato_variable_1 on tipo_dato_variable_1.numero = variable.tipo_dato
;
