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
exec xsp.dropone('view', 'consulta_rol');
create view consulta_rol as
select
    rol.id_rol,
    rol.version_rol,
    rol.codigo_rol,
    rol.nombre_rol,
    rol.descripcion_rol,
    rol.es_super_rol,
    rol.es_rol_especial,
    rol.numero_tipo_rol,
        tipo_rol_1.numero_tipo_rol as numero_tipo_rol_1,
        tipo_rol_1.codigo_tipo_rol as codigo_tipo_rol_1
    from rol
    left outer join tipo_rol tipo_rol_1 on tipo_rol_1.numero_tipo_rol = rol.numero_tipo_rol
;
