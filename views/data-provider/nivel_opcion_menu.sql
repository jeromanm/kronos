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
exec xsp.dropone('view', 'consulta_nivel_opcion_menu');
create view consulta_nivel_opcion_menu as
select
    nivel_opcion_menu.numero_nivel_opcion_menu,
    nivel_opcion_menu.codigo_nivel_opcion_menu,
    nivel_opcion_menu.digitos_nivel_opcion_menu
    from nivel_opcion_menu
;
