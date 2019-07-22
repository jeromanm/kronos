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
exec xsp.dropone('view', 'consulta_consulta_ciudadano');
create view consulta_consulta_ciudadano as
select
    consulta_ciudadano.id,
    consulta_ciudadano.version,
    consulta_ciudadano.codigo,
    consulta_ciudadano.canal_atencion,
    consulta_ciudadano.clasificacion_consulta,
    consulta_ciudadano.fecha_recepcion,
    consulta_ciudadano.numero_sime,
    consulta_ciudadano.censo,
    consulta_ciudadano.cedula_recurrente,
    consulta_ciudadano.cedula_no_identificacion,
    consulta_ciudadano.nombre_recurrente,
    consulta_ciudadano.departamento,
    consulta_ciudadano.distrito,
    consulta_ciudadano.indigena,
    consulta_ciudadano.clase_pension,
    consulta_ciudadano.persona,
    consulta_ciudadano.pension,
    consulta_ciudadano.reclamo,
    consulta_ciudadano.tramite,
    consulta_ciudadano.descripcion,
    consulta_ciudadano.dependencia,
    consulta_ciudadano.fecha_dependencia,
    consulta_ciudadano.dias_dependencia,
    consulta_ciudadano.situacion,
    consulta_ciudadano.destino,
    consulta_ciudadano.observaciones,
    consulta_ciudadano.estado,
    consulta_ciudadano.fecha_finiquito,
    consulta_ciudadano.dias_reclamo,
    consulta_ciudadano.dias_sime,
    consulta_ciudadano.cantidad_consultas,
    consulta_ciudadano.fecha_ultima_consulta,
    consulta_ciudadano.contacto,
    consulta_ciudadano.numero_telefono_contacto,
    consulta_ciudadano.telefono_celular,
    consulta_ciudadano.contacto_correo,
    consulta_ciudadano.fecha_aviso_recurrente,
    consulta_ciudadano.usuario_aviso_recurrente,
    consulta_ciudadano.canal_aviso_recurrente,
    consulta_ciudadano.dias_transcurrido,
    consulta_ciudadano.estado_consulta,
        canal_atencion_1.numero as numero_1,
        canal_atencion_1.codigo as codigo_1,
        clasificacion_consulta_2.codigo as codigo_2,
        clasificacion_consulta_2.nombre as nombre_2,
        censo_persona_4.codigo as codigo_4,
        cedula_5.numero as numero_5,
        cedula_5.nombre as nombre_5,
        departamento_6.codigo as codigo_6,
        departamento_6.nombre as nombre_6,
        distrito_7.codigo as codigo_7,
        distrito_7.nombre as nombre_7,
        clase_pension_8.codigo as codigo_8,
        clase_pension_8.nombre as nombre_8,
        persona_9.codigo as codigo_9,
        persona_9.nombre as nombre_9,
        pension_10.codigo as codigo_10,
        reclamo_pension_11.codigo as codigo_11,
        tramite_administrativo_12.codigo as codigo_12,
        usuario_13.codigo_usuario as codigo_usuario_13,
        usuario_13.nombre_usuario as nombre_usuario_13,
        canal_atencion_14.numero as numero_14,
        canal_atencion_14.codigo as codigo_14,
        estado_consulta_15.numero as numero_15,
        estado_consulta_15.codigo as codigo_15
    from consulta_ciudadano
    inner join canal_atencion canal_atencion_1 on canal_atencion_1.numero = consulta_ciudadano.canal_atencion
    inner join clasificacion_consulta clasificacion_consulta_2 on clasificacion_consulta_2.id = consulta_ciudadano.clasificacion_consulta
    left outer join censo_persona censo_persona_4 on censo_persona_4.id = consulta_ciudadano.censo
    left outer join cedula cedula_5 on cedula_5.id = consulta_ciudadano.cedula_recurrente
    left outer join departamento departamento_6 on departamento_6.id = consulta_ciudadano.departamento
    left outer join distrito distrito_7 on distrito_7.id = consulta_ciudadano.distrito
    left outer join clase_pension clase_pension_8 on clase_pension_8.id = consulta_ciudadano.clase_pension
    left outer join persona persona_9 on persona_9.id = consulta_ciudadano.persona
    left outer join pension pension_10 on pension_10.id = consulta_ciudadano.pension
    left outer join reclamo_pension reclamo_pension_11 on reclamo_pension_11.id = consulta_ciudadano.reclamo
    left outer join tramite_administrativo tramite_administrativo_12 on tramite_administrativo_12.id = consulta_ciudadano.tramite
    left outer join usuario usuario_13 on usuario_13.id_usuario = consulta_ciudadano.usuario_aviso_recurrente
    left outer join canal_atencion canal_atencion_14 on canal_atencion_14.numero = consulta_ciudadano.canal_aviso_recurrente
    inner join estado_consulta estado_consulta_15 on estado_consulta_15.numero = consulta_ciudadano.estado_consulta
;
