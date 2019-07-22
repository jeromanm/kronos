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
exec xsp.dropone('view', 'consulta_rol_usuario');
create view consulta_rol_usuario as
select
    rol_usuario.id_rol_usuario,
    rol_usuario.version_rol_usuario,
    rol_usuario.id_rol,
    rol_usuario.id_usuario,
        rol_1.codigo_rol as codigo_rol_1,
        rol_1.nombre_rol as nombre_rol_1,
        usuario_2.codigo_usuario as codigo_usuario_2,
        usuario_2.nombre_usuario as nombre_usuario_2
    from rol_usuario
    inner join rol rol_1 on rol_1.id_rol = rol_usuario.id_rol
    inner join usuario usuario_2 on usuario_2.id_usuario = rol_usuario.id_usuario
;
