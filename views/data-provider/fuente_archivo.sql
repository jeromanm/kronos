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
exec xsp.dropone('view', 'consulta_fuente_archivo');
create view consulta_fuente_archivo as
select
    fuente_archivo.id,
    fuente_archivo.version,
    fuente_archivo.codigo,
    fuente_archivo.nombre,
    fuente_archivo.descripcion
    from fuente_archivo
;
