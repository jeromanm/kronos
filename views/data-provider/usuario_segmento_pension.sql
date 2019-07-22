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
exec xsp.dropone('view', 'consulta_usua_segm_pensi_52496');
create view consulta_usua_segm_pensi_52496 as
select
    usuario_segmento_pension.id,
    usuario_segmento_pension.version,
    usuario_segmento_pension.codigo,
    usuario_segmento_pension.usuario,
    usuario_segmento_pension.segmento_pension,
        usuario_1.codigo_usuario as codigo_usuario_1,
        usuario_1.nombre_usuario as nombre_usuario_1,
        segmento_pension_2.codigo as codigo_2,
        segmento_pension_2.nombre as nombre_2
    from usuario_segmento_pension
    inner join usuario usuario_1 on usuario_1.id_usuario = usuario_segmento_pension.usuario
    inner join segmento_pension segmento_pension_2 on segmento_pension_2.id = usuario_segmento_pension.segmento_pension
;
