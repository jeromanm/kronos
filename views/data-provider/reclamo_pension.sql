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
exec xsp.dropone('view', 'consulta_reclamo_pension');
create view consulta_reclamo_pension as
select
    reclamo_pension.id,
    reclamo_pension.version,
    reclamo_pension.codigo,
    reclamo_pension.pension,
    reclamo_pension.tipo,
    reclamo_pension.descripcion,
    reclamo_pension.numero_sime,
    reclamo_pension.archivo,
    reclamo_pension.linea,
    reclamo_pension.estado,
    reclamo_pension.fecha_transicion,
    reclamo_pension.usuario_transicion,
    reclamo_pension.observaciones,
    reclamo_pension.dictamen_denegar,
    reclamo_pension.fecha_dictamen_denegar,
    reclamo_pension.resumen_dictamen_denegar,
    reclamo_pension.antecedente_denegar,
    reclamo_pension.antecedente_denegar_uno,
    reclamo_pension.disposicion_den_uno,
    reclamo_pension.disposicion_den_dos,
    reclamo_pension.disposicion_den_tres,
    reclamo_pension.opinion_den_uno,
    reclamo_pension.opinion_den_dos,
    reclamo_pension.opinion_den_tres,
    reclamo_pension.causa_denegar,
    reclamo_pension.otras_causas_denegar,
    reclamo_pension.resolucion_denegar,
    reclamo_pension.fecha_resolucion_denegar,
    reclamo_pension.resumen_resolucion_denegar,
    reclamo_pension.dictamen_otorgar,
    reclamo_pension.fecha_dictamen_otorgar,
    reclamo_pension.resumen_dictamen_otorgar,
    reclamo_pension.antecedente_dic_oto,
    reclamo_pension.antecedente_dic_oto_uno,
    reclamo_pension.disposicion_dic_oto_uno,
    reclamo_pension.disposicion_dic_oto_dos,
    reclamo_pension.disposicion_dic_oto_tres,
    reclamo_pension.opinion_dic_oto_uno,
    reclamo_pension.opinion_dic_oto_dos,
    reclamo_pension.opinion_dic_oto_tres,
    reclamo_pension.resolucion_otorgar,
    reclamo_pension.fecha_resolucion_otorgar,
    reclamo_pension.resumen_resolucion_otorgar,
    reclamo_pension.dictamen_rein_denegar,
    reclamo_pension.fecha_dictamen_rein_denegar,
    reclamo_pension.resu_dicta_rein_dene,
    reclamo_pension.antecedente_rein_dene,
    reclamo_pension.antecedente_rein_dene_uno,
    reclamo_pension.disposicion_rein_uno,
    reclamo_pension.disposicion_rein_dos,
    reclamo_pension.disposicion_rein_tres,
    reclamo_pension.opinion_rein_uno,
    reclamo_pension.opinion_rein_dos,
    reclamo_pension.opinion_rein_tres,
    reclamo_pension.resol_rein_denegar,
    reclamo_pension.fecha_resol_rein_denegar,
    reclamo_pension.resum_resol_rein_dengar,
    reclamo_pension.dictamen_reco_otorgar,
    reclamo_pension.fecha_dictamen_reco_otorgar,
    reclamo_pension.resu_dict_reco_otor,
    reclamo_pension.antecedente_reco_oto,
    reclamo_pension.antecedente_reco_oto_uno,
    reclamo_pension.disposicion_reco_oto_uno,
    reclamo_pension.disposicion_reco_oto_dos,
    reclamo_pension.disposicion_reco_oto_tres,
    reclamo_pension.opinion_reco_oto_uno,
    reclamo_pension.opinion_reco_oto_dos,
    reclamo_pension.opinion_reco_oto_tres,
    reclamo_pension.resolucion_reco_oto,
    reclamo_pension.fecha_resolucion_reco_oto,
    reclamo_pension.resumen_resolucion_reco_oto,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        tipo_reclamo_2.numero as numero_2,
        tipo_reclamo_2.codigo as codigo_2,
        carga_archivo_4.codigo as codigo_4,
        estado_reclamo_5.numero as numero_5,
        estado_reclamo_5.codigo as codigo_5,
        usuario_6.codigo_usuario as codigo_usuario_6,
        usuario_6.nombre_usuario as nombre_usuario_6,
        causa_denegar_reclamo_7.numero as numero_7,
        causa_denegar_reclamo_7.codigo as codigo_7
    from reclamo_pension
    inner join(pension pension_1
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = reclamo_pension.pension
    inner join tipo_reclamo tipo_reclamo_2 on tipo_reclamo_2.numero = reclamo_pension.tipo
    left outer join carga_archivo carga_archivo_4 on carga_archivo_4.id = reclamo_pension.archivo
    inner join estado_reclamo estado_reclamo_5 on estado_reclamo_5.numero = reclamo_pension.estado
    left outer join usuario usuario_6 on usuario_6.id_usuario = reclamo_pension.usuario_transicion
    left outer join causa_denegar_reclamo causa_denegar_reclamo_7 on causa_denegar_reclamo_7.numero = reclamo_pension.causa_denegar
;
