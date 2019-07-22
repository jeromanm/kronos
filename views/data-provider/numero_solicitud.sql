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
exec xsp.dropone('view', 'consulta_numero_solicitud');
create view consulta_numero_solicitud as
select
    numero_solicitud.id,
    numero_solicitud.codigo,
    numero_solicitud.fecha,
    numero_solicitud.monto_solicitud,
    numero_solicitud.concepto,
    numero_solicitud.detalle
    from numero_solicitud
;
