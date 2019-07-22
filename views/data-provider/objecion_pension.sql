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
exec xsp.dropone('view', 'consulta_objecion_pension');
create view consulta_objecion_pension as
select
    objecion_pension.id,
    objecion_pension.version,
    objecion_pension.codigo,
    objecion_pension.pension,
    objecion_pension.regla,
    objecion_pension.objecion_invalida,
    objecion_pension.fecha_transicion,
    objecion_pension.usuario_transicion,
    objecion_pension.observaciones,
    objecion_pension.comentarios,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            persona_1_2.codigo as codigo_1_2,
            persona_1_2.nombre as nombre_1_2,
            persona_1_2.icv as icv_1_2,
            persona_1_2.direccion as direccion_1_2,
            persona_1_2.telefono_linea_baja as telefono_linea_baja_1_2,
            persona_1_2.edad as edad_1_2,
                departamento_1_2_11.nombre as nombre_1_2_11,
                distrito_1_2_12.nombre as nombre_1_2_12,
                barrio_1_2_14.nombre as nombre_1_2_14,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        regla_clase_pension_2.codigo as codigo_2,
        regla_clase_pension_2.nombre as nombre_2,
        usuario_3.codigo_usuario as codigo_usuario_3,
        usuario_3.nombre_usuario as nombre_usuario_3
    from objecion_pension
    inner join(pension pension_1
        inner join(persona persona_1_2
            inner join departamento departamento_1_2_11 on departamento_1_2_11.id = persona_1_2.departamento
            inner join distrito distrito_1_2_12 on distrito_1_2_12.id = persona_1_2.distrito
            left outer join barrio barrio_1_2_14 on barrio_1_2_14.id = persona_1_2.barrio)
        on persona_1_2.id = pension_1.persona
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = objecion_pension.pension
    inner join regla_clase_pension regla_clase_pension_2 on regla_clase_pension_2.id = objecion_pension.regla
    left outer join usuario usuario_3 on usuario_3.id_usuario = objecion_pension.usuario_transicion
;
