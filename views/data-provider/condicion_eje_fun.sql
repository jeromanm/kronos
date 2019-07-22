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
exec xsp.dropone('view', 'consulta_condicion_eje_fun');
create view consulta_condicion_eje_fun as
select
    condicion_eje_fun.numero_condicion_eje_fun,
    condicion_eje_fun.codigo_condicion_eje_fun
    from condicion_eje_fun
;
