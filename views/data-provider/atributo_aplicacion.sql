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
exec xsp.dropone('view', 'consulta_atributo_aplicacion');
create view consulta_atributo_aplicacion as
select
    atributo_aplicacion.id,
    atributo_aplicacion.version,
    atributo_aplicacion.clave,
    atributo_aplicacion.valor
    from atributo_aplicacion
;
