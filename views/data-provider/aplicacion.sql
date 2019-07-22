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
exec xsp.dropone('view', 'consulta_aplicacion');
create view consulta_aplicacion as
select
    aplicacion.id_aplicacion,
    aplicacion.version_aplicacion,
    aplicacion.codigo_aplicacion,
    aplicacion.nombre_aplicacion,
    aplicacion.descripcion_aplicacion,
    aplicacion.servidor_aplicacion,
    aplicacion.puerto_aplicacion,
    aplicacion.url_aplicacion,
    aplicacion.es_publica,
    aplicacion.es_especial
    from aplicacion
;
