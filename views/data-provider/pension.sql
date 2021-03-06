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
exec xsp.dropone('view', 'consulta_pension');
create view consulta_pension as
select
    pension.id,
    pension.version,
    pension.codigo,
    pension.clase,
    pension.persona,
    pension.causante,
    pension.saldo_inicial,
    pension.saldo_actual,
    pension.monto_pagado,
    pension.numero_sime,
    pension.numero_sime_entrada,
    pension.archivo,
    pension.linea,
    pension.comentarios,
    pension.estado,
    pension.fecha_transicion,
    pension.usuario_transicion,
    pension.observaciones,
    pension.activa,
    pension.fecha_activar,
    pension.usuario_activar,
    pension.observaciones_activar,
    pension.fecha_inactivar,
    pension.usuario_inactivar,
    pension.observaciones_inactivar,
    pension.irregular,
    pension.fecha_irregular,
    pension.tiene_objecion,
    pension.falta_requisito,
    pension.tiene_denuncia,
    pension.tiene_reclamo,
    pension.tiene_sentencia,
    pension.dictamen_denegar,
    pension.fecha_dictamen_denegar,
    pension.resumen_dictamen_denegar,
    pension.antecedente_dene,
    pension.antecedente_dene_uno,
    pension.disposicion_dene_uno,
    pension.disposicion_dene_dos,
    pension.disposicion_dene_tres,
    pension.opinion_dene_uno,
    pension.opinion_dene_dos,
    pension.opinion_dene_tres,
    pension.causa_denegar,
    pension.otras_causas_denegar,
    pension.resolucion_denegar,
    pension.fecha_resolucion_denegar,
    pension.resumen_resolucion_denegar,
    pension.reclamo_otorgar,
    pension.dictamen_otorgar,
    pension.fecha_dictamen_otorgar,
    pension.resumen_dictamen_otorgar,
    pension.antecedente_oto,
    pension.antecedente_oto_uno,
    pension.disposicion_oto_uno,
    pension.disposicion_oto_dos,
    pension.disposicion_oto_tres,
    pension.opinion_oto_uno,
    pension.opinion_oto_dos,
    pension.opinion_oto_tres,
    pension.resolucion_otorgar,
    pension.fecha_resolucion_otorgar,
    pension.antecedente_resol_oto,
    pension.antecedente_resol_oto_uno,
    pension.disposicion_resol_oto_uno,
    pension.disposicion_resol_oto_dos,
    pension.disposicion_resol_oto_tres,
    pension.opinion_resol_oto_uno,
    pension.opinion_resol_oto_dos,
    pension.opinion_resol_oto_tres,
    pension.resumen_resol_oto_uno,
    pension.resumen_resol_oto_dos,
    pension.resumen_resol_oto_tres,
    pension.resumen_resolucion_otorgar,
    pension.dictamen_revocar,
    pension.fecha_dictamen_revocar,
    pension.resumen_dictamen_revocar,
    pension.antecedente_revo,
    pension.antecedente_revo_uno,
    pension.disposicion_revo_uno,
    pension.disposicion_revo_dos,
    pension.disposicion_revo_tres,
    pension.opinion_revo_uno,
    pension.opinion_revo_dos,
    pension.opinion_revo_tres,
    pension.causa_revocar,
    pension.otras_causas_revocar,
    pension.resolucion_revocar,
    pension.fecha_resolucion_revocar,
    pension.resumen_resolucion_revocar,
    pension.reclamo_reactivar,
    pension.causa_finalizar,
    pension.otras_causas_finalizar,
    pension.cant_planilla_exceso,
    pension.monto_exceso,
    pension.monto_reintegro,
    pension.monto_red_bancaria,
    pension.monto_deuda,
    pension.expediente_acuerdo,
    pension.descripcion_acuerdo,
    pension.fecha_acuerdo,
    pension.persona_deudor,
    pension.monto_cuota,
    pension.saldo_deudor,
    pension.observaciones_anular_acuerdo,
    pension.dictamen_sent,
    pension.fecha_dictamen_sent,
    pension.resumen_dictamen_sent,
    pension.antecedente_sent,
    pension.antecedente_sent_uno,
    pension.disposicion_sent_uno,
    pension.disposicion_sent_dos,
    pension.disposicion_sent_tres,
    pension.opinion_sent_uno,
    pension.opinion_sent_dos,
    pension.opinion_sent_tres,
    pension.resolucion_sent,
    pension.fecha_resolucion_sent,
    pension.resumen_resol_otorgar_sent,
    pension.sime_notificacion,
    pension.fecha_notificacion,
    pension.numero_notificacion,
    pension.retirado,
    pension.cedula_retiro,
    case when current_date >= util_dateadd(pension.fecha_notificacion, 25, 'days') then 'true' else 'false' end as notifica,
    pension.usuario_notificacion,
    pension.numero_ley,
    pension.fecha_conces,
    pension.monto_graciable,
    pension.mdn,
    pension.fecha_mdn,
    pension.permite_menor,
    pension.validacion_estricta,
    pension.segmento,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        persona_2.codigo as codigo_2,
        persona_2.nombre as nombre_2,
        persona_2.indigena as indigena_2,
            sexo_persona_2_2.codigo as codigo_2_2,
            departamento_2_11.codigo as codigo_2_11,
            departamento_2_11.nombre as nombre_2_11,
            distrito_2_12.codigo as codigo_2_12,
            distrito_2_12.nombre as nombre_2_12,
        persona_3.codigo as codigo_3,
        persona_3.nombre as nombre_3,
        carga_archivo_6.codigo as codigo_6,
        estado_pension_7.numero as numero_7,
        estado_pension_7.codigo as codigo_7,
        usuario_8.codigo_usuario as codigo_usuario_8,
        usuario_8.nombre_usuario as nombre_usuario_8,
        usuario_9.codigo_usuario as codigo_usuario_9,
        usuario_9.nombre_usuario as nombre_usuario_9,
        usuario_10.codigo_usuario as codigo_usuario_10,
        usuario_10.nombre_usuario as nombre_usuario_10,
        causa_denegar_pension_11.numero as numero_11,
        causa_denegar_pension_11.codigo as codigo_11,
        reclamo_pension_12.codigo as codigo_12,
        causa_revocar_pension_13.numero as numero_13,
        causa_revocar_pension_13.codigo as codigo_13,
        reclamo_pension_14.codigo as codigo_14,
        causa_finalizar_pension_15.numero as numero_15,
        causa_finalizar_pension_15.codigo as codigo_15,
        persona_16.codigo as codigo_16,
        persona_16.nombre as nombre_16,
        usuario_18.codigo_usuario as codigo_usuario_18,
        usuario_18.nombre_usuario as nombre_usuario_18,
        segmento_pension_19.codigo as codigo_19,
        segmento_pension_19.nombre as nombre_19
    from pension
    inner join clase_pension clase_pension_1 on clase_pension_1.id = pension.clase
    inner join(persona persona_2
        left outer join sexo_persona sexo_persona_2_2 on sexo_persona_2_2.numero = persona_2.sexo
        inner join departamento departamento_2_11 on departamento_2_11.id = persona_2.departamento
        inner join distrito distrito_2_12 on distrito_2_12.id = persona_2.distrito)
    on persona_2.id = pension.persona
    left outer join persona persona_3 on persona_3.id = pension.causante
    left outer join carga_archivo carga_archivo_6 on carga_archivo_6.id = pension.archivo
    inner join estado_pension estado_pension_7 on estado_pension_7.numero = pension.estado
    left outer join usuario usuario_8 on usuario_8.id_usuario = pension.usuario_transicion
    left outer join usuario usuario_9 on usuario_9.id_usuario = pension.usuario_activar
    left outer join usuario usuario_10 on usuario_10.id_usuario = pension.usuario_inactivar
    left outer join causa_denegar_pension causa_denegar_pension_11 on causa_denegar_pension_11.numero = pension.causa_denegar
    left outer join reclamo_pension reclamo_pension_12 on reclamo_pension_12.id = pension.reclamo_otorgar
    left outer join causa_revocar_pension causa_revocar_pension_13 on causa_revocar_pension_13.numero = pension.causa_revocar
    left outer join reclamo_pension reclamo_pension_14 on reclamo_pension_14.id = pension.reclamo_reactivar
    left outer join causa_finalizar_pension causa_finalizar_pension_15 on causa_finalizar_pension_15.numero = pension.causa_finalizar
    left outer join persona persona_16 on persona_16.id = pension.persona_deudor
    left outer join usuario usuario_18 on usuario_18.id_usuario = pension.usuario_notificacion
    left outer join segmento_pension segmento_pension_19 on segmento_pension_19.id = pension.segmento
;
