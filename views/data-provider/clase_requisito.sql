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
exec xsp.dropone('view', 'consulta_clase_requisito');
create view consulta_clase_requisito as
select
    clase_requisito.id,
    clase_requisito.version,
    clase_requisito.codigo,
    clase_requisito.nombre,
    clase_requisito.tiene_fecha_expedicion,
    clase_requisito.tiene_fecha_vencimiento
    from clase_requisito
;
