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
exec xsp.dropone('view', 'consulta_departamento');
create view consulta_departamento as
select
    departamento.id,
    departamento.version,
    departamento.codigo,
    departamento.nombre,
    departamento.region,
        region_1.numero as numero_1,
        region_1.codigo as codigo_1
    from departamento
    inner join region region_1 on region_1.numero = departamento.region
;
