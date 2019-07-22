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
exec xsp.dropone('view', 'consulta_denuncia_pension');
create view consulta_denuncia_pension as
select
    denuncia_pension.id,
    denuncia_pension.version,
    denuncia_pension.codigo,
    denuncia_pension.pension,
    denuncia_pension.descripcion,
    denuncia_pension.numero_sime,
    denuncia_pension.archivo,
    denuncia_pension.linea,
    denuncia_pension.estado,
    denuncia_pension.fecha_transicion,
    denuncia_pension.usuario_transicion,
    denuncia_pension.observaciones,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        carga_archivo_3.codigo as codigo_3,
        estado_denuncia_4.numero as numero_4,
        estado_denuncia_4.codigo as codigo_4,
        usuario_5.codigo_usuario as codigo_usuario_5,
        usuario_5.nombre_usuario as nombre_usuario_5
    from denuncia_pension
    inner join(pension pension_1
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = denuncia_pension.pension
    left outer join carga_archivo carga_archivo_3 on carga_archivo_3.id = denuncia_pension.archivo
    inner join estado_denuncia estado_denuncia_4 on estado_denuncia_4.numero = denuncia_pension.estado
    left outer join usuario usuario_5 on usuario_5.id_usuario = denuncia_pension.usuario_transicion
;
