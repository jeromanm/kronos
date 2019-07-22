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
exec xsp.dropone('view', 'consulta_grupo_pension');
create view consulta_grupo_pension as
select
    grupo_pension.id,
    grupo_pension.version,
    grupo_pension.codigo,
    grupo_pension.nombre,
    grupo_pension.ley,
    grupo_pension.fecha_ley,
    grupo_pension.descripcion
    from grupo_pension
;
