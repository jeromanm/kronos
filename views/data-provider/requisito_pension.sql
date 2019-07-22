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
exec xsp.dropone('view', 'consulta_requisito_pension');
create view consulta_requisito_pension as
select
    requisito_pension.id,
    requisito_pension.version,
    requisito_pension.codigo,
    requisito_pension.descripcion,
    requisito_pension.pension,
    requisito_pension.clase,
    requisito_pension.fecha_expedicion,
    requisito_pension.fecha_vencimiento,
    requisito_pension.numero_sime,
    requisito_pension.archivo,
    requisito_pension.linea,
    requisito_pension.estado,
    requisito_pension.fecha_transicion,
    requisito_pension.usuario_transicion,
    requisito_pension.causa_rechazo,
    requisito_pension.observaciones,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        requisito_clase_pension_2.codigo as codigo_2,
        requisito_clase_pension_2.nombre as nombre_2,
        carga_archivo_4.codigo as codigo_4,
        estado_requisito_5.numero as numero_5,
        estado_requisito_5.codigo as codigo_5,
        usuario_6.codigo_usuario as codigo_usuario_6,
        usuario_6.nombre_usuario as nombre_usuario_6,
        causa_rechazar_requisito_7.numero as numero_7,
        causa_rechazar_requisito_7.codigo as codigo_7
    from requisito_pension
    inner join(pension pension_1
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = requisito_pension.pension
    inner join requisito_clase_pension requisito_clase_pension_2 on requisito_clase_pension_2.id = requisito_pension.clase
    left outer join carga_archivo carga_archivo_4 on carga_archivo_4.id = requisito_pension.archivo
    inner join estado_requisito estado_requisito_5 on estado_requisito_5.numero = requisito_pension.estado
    left outer join usuario usuario_6 on usuario_6.id_usuario = requisito_pension.usuario_transicion
    left outer join causa_rechazar_requisito causa_rechazar_requisito_7 on causa_rechazar_requisito_7.numero = requisito_pension.causa_rechazo
;
