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
exec xsp.dropone('view', 'consulta_clase_concepto');
create view consulta_clase_concepto as
select
    clase_concepto.id,
    clase_concepto.version,
    clase_concepto.codigo,
    clase_concepto.nombre,
    clase_concepto.tipo_concepto,
        tipo_concepto_1.numero as numero_1,
        tipo_concepto_1.codigo as codigo_1
    from clase_concepto
    inner join tipo_concepto tipo_concepto_1 on tipo_concepto_1.numero = clase_concepto.tipo_concepto
;
