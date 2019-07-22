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
exec xsp.dropone('view', 'consulta_tipo_parametro_dom');
create view consulta_tipo_parametro_dom as
select
    tipo_parametro_dom.numero_tipo_parametro_dom,
    tipo_parametro_dom.codigo_tipo_parametro_dom,
    tipo_parametro_dom.codigo_propiedad_interfaz,
    tipo_parametro_dom.nombre_interfaz,
    tipo_parametro_dom.etiqueta_parametro
    from tipo_parametro_dom
;
