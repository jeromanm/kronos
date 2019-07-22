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
exec xsp.dropone('view', 'consulta_opcion_menu');
create view consulta_opcion_menu as
select
    opcion_menu.id_opcion_menu,
    opcion_menu.version_opcion_menu,
    opcion_menu.codigo_opcion_menu,
    opcion_menu.nombre_opcion_menu,
    opcion_menu.descripcion_opcion_menu,
    opcion_menu.url_opcion_menu,
    opcion_menu.secuencia_opcion_menu,
    opcion_menu.clave_opcion_menu,
    opcion_menu.es_opcion_menu_inactiva,
    opcion_menu.es_opcion_menu_sincronizada,
    opcion_menu.es_especial,
    opcion_menu.id_opcion_menu_superior,
    opcion_menu.numero_tipo_nodo,
    opcion_menu.numero_nivel_opcion_menu,
        opcion_menu_1.codigo_opcion_menu as codigo_opcion_menu_1,
        opcion_menu_1.nombre_opcion_menu as nombre_opcion_menu_1,
        tipo_nodo_2.numero_tipo_nodo as numero_tipo_nodo_2,
        tipo_nodo_2.codigo_tipo_nodo as codigo_tipo_nodo_2,
        nivel_opcion_menu_3.numero_nivel_opcion_menu as numero_nivel_opcion_menu_3,
        nivel_opcion_menu_3.codigo_nivel_opcion_menu as codigo_nivel_opcion_menu_3
    from opcion_menu
    left outer join opcion_menu opcion_menu_1 on opcion_menu_1.id_opcion_menu = opcion_menu.id_opcion_menu_superior
    left outer join tipo_nodo tipo_nodo_2 on tipo_nodo_2.numero_tipo_nodo = opcion_menu.numero_tipo_nodo
    left outer join nivel_opcion_menu nivel_opcion_menu_3 on nivel_opcion_menu_3.numero_nivel_opcion_menu = opcion_menu.numero_nivel_opcion_menu
;
