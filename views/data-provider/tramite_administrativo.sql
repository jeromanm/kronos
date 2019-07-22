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
exec xsp.dropone('view', 'consulta_tramite_adminis_72271');
create view consulta_tramite_adminis_72271 as
select
    tramite_administrativo.id,
    tramite_administrativo.version,
    tramite_administrativo.codigo,
    tramite_administrativo.pension,
    tramite_administrativo.tipo,
    tramite_administrativo.descripcion,
    tramite_administrativo.numero_sime,
    tramite_administrativo.numero_sime_requisitos,
    tramite_administrativo.archivo,
    tramite_administrativo.linea,
    tramite_administrativo.estado,
    tramite_administrativo.fecha_transicion,
    tramite_administrativo.usuario_transicion,
    tramite_administrativo.observaciones,
    tramite_administrativo.dictamen_denegar,
    tramite_administrativo.fecha_dictamen_denegar,
    tramite_administrativo.resumen_dictamen_denegar,
    tramite_administrativo.antecedente_dene,
    tramite_administrativo.antecedente_dene_uno,
    tramite_administrativo.disposicion_dene_uno,
    tramite_administrativo.disposicion_dene_dos,
    tramite_administrativo.disposicion_dene_tres,
    tramite_administrativo.opinion_dene_uno,
    tramite_administrativo.opinion_dene_dos,
    tramite_administrativo.opinion_dene_tres,
    tramite_administrativo.causa_denegar,
    tramite_administrativo.otras_causas_denegar,
    tramite_administrativo.resolucion_denegar,
    tramite_administrativo.fecha_resolucion_denegar,
    tramite_administrativo.resumen_resolucion_denegar,
    tramite_administrativo.dictamen_habe_atrasado,
    tramite_administrativo.fecha_dictamen_habe_atrasado,
    tramite_administrativo.resumen_dictamen_habe_atrasado,
    tramite_administrativo.antecedente_habe_atr,
    tramite_administrativo.antecedente_habe_atr_uno,
    tramite_administrativo.disposicion_habe_atr_uno,
    tramite_administrativo.disposicion_habe_atr_dos,
    tramite_administrativo.disposicion_habe_atr_tres,
    tramite_administrativo.opinion_habe_atr_uno,
    tramite_administrativo.opinion_habe_atr_dos,
    tramite_administrativo.opinion_habe_atr_tres,
    tramite_administrativo.resolucion_habe_atrasado,
    tramite_administrativo.fecha_resolucion_habe_atrasado,
    tramite_administrativo.resumen_resol_habe_atrasado,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        tipo_tramite_administrativo_2.numero as numero_2,
        tipo_tramite_administrativo_2.codigo as codigo_2,
        carga_archivo_5.codigo as codigo_5,
        estado_tramite_administrativ_6.numero as numero_6,
        estado_tramite_administrativ_6.codigo as codigo_6,
        usuario_7.codigo_usuario as codigo_usuario_7,
        usuario_7.nombre_usuario as nombre_usuario_7,
        causa_denegar_reclamo_8.numero as numero_8,
        causa_denegar_reclamo_8.codigo as codigo_8
    from tramite_administrativo
    inner join(pension pension_1
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = tramite_administrativo.pension
    inner join tipo_tramite_administrativo tipo_tramite_administrativo_2 on tipo_tramite_administrativo_2.numero = tramite_administrativo.tipo
    left outer join carga_archivo carga_archivo_5 on carga_archivo_5.id = tramite_administrativo.archivo
    inner join estado_tramite_administrativo estado_tramite_administrativ_6 on estado_tramite_administrativ_6.numero = tramite_administrativo.estado
    left outer join usuario usuario_7 on usuario_7.id_usuario = tramite_administrativo.usuario_transicion
    left outer join causa_denegar_reclamo causa_denegar_reclamo_8 on causa_denegar_reclamo_8.numero = tramite_administrativo.causa_denegar
;
