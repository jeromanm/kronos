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
exec xsp.dropone('view', 'consulta_archivo_adjunto');
create view consulta_archivo_adjunto as
select
    archivo_adjunto.id,
    archivo_adjunto.archivo_servidor,
    archivo_adjunto.archivo_cliente,
    archivo_adjunto.propietario,
    archivo_adjunto.codigo_usuario_propietario,
    archivo_adjunto.nombre_usuario_propietario,
    archivo_adjunto.fecha_hora_carga,
    archivo_adjunto.tipo_contenido,
    archivo_adjunto.longitud,
    archivo_adjunto.octetos,
    archivo_adjunto.restaurable,
        usuario_1.codigo_usuario as codigo_usuario_1,
        usuario_1.nombre_usuario as nombre_usuario_1
    from archivo_adjunto
    left outer join usuario usuario_1 on usuario_1.id_usuario = archivo_adjunto.propietario
;
