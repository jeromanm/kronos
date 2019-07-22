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
exec xsp.dropone('view', 'consulta_metodo_concepto');
create view consulta_metodo_concepto as
select
    metodo_concepto.numero,
    metodo_concepto.codigo,
    metodo_concepto.requiere_monto,
    metodo_concepto.requiere_jornales,
    metodo_concepto.requiere_porcentaje
    from metodo_concepto
;
