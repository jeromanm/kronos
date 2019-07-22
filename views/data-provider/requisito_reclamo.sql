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
exec xsp.dropone('view', 'consulta_requisito_reclamo');
create view consulta_requisito_reclamo as
select
    requisito_reclamo.id,
    requisito_reclamo.version,
    requisito_reclamo.codigo,
    requisito_reclamo.descripcion,
    requisito_reclamo.reclamo,
    requisito_reclamo.clase,
    requisito_reclamo.fecha_expedicion,
    requisito_reclamo.fecha_vencimiento,
    requisito_reclamo.numero_sime,
    requisito_reclamo.archivo,
    requisito_reclamo.linea,
    requisito_reclamo.estado,
    requisito_reclamo.fecha_transicion,
    requisito_reclamo.usuario_transicion,
    requisito_reclamo.causa_rechazo,
    requisito_reclamo.observaciones,
        reclamo_pension_1.codigo as codigo_1,
            pension_1_1.segmento as segmento_1_1,
                segmento_pension_1_1_19.codigo as codigo_1_1_19,
                segmento_pension_1_1_19.nombre as nombre_1_1_19,
        requisito_tipo_reclamo_2.codigo as codigo_2,
        requisito_tipo_reclamo_2.nombre as nombre_2,
        carga_archivo_4.codigo as codigo_4,
        estado_requisito_5.numero as numero_5,
        estado_requisito_5.codigo as codigo_5,
        usuario_6.codigo_usuario as codigo_usuario_6,
        usuario_6.nombre_usuario as nombre_usuario_6,
        causa_rechazar_requisito_7.numero as numero_7,
        causa_rechazar_requisito_7.codigo as codigo_7
    from requisito_reclamo
    inner join(reclamo_pension reclamo_pension_1
        inner join(pension pension_1_1
            left outer join segmento_pension segmento_pension_1_1_19 on segmento_pension_1_1_19.id = pension_1_1.segmento)
        on pension_1_1.id = reclamo_pension_1.pension)
    on reclamo_pension_1.id = requisito_reclamo.reclamo
    inner join requisito_tipo_reclamo requisito_tipo_reclamo_2 on requisito_tipo_reclamo_2.id = requisito_reclamo.clase
    left outer join carga_archivo carga_archivo_4 on carga_archivo_4.id = requisito_reclamo.archivo
    inner join estado_requisito estado_requisito_5 on estado_requisito_5.numero = requisito_reclamo.estado
    left outer join usuario usuario_6 on usuario_6.id_usuario = requisito_reclamo.usuario_transicion
    left outer join causa_rechazar_requisito causa_rechazar_requisito_7 on causa_rechazar_requisito_7.numero = requisito_reclamo.causa_rechazo
;
