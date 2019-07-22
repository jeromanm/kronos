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
exec xsp.dropone('view', 'consulta_distrito');
create view consulta_distrito as
select
    distrito.id,
    distrito.version,
    distrito.codigo,
    distrito.nombre,
    distrito.departamento,
        departamento_1.codigo as codigo_1,
        departamento_1.nombre as nombre_1
    from distrito
    inner join departamento departamento_1 on departamento_1.id = distrito.departamento
;
