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
exec xsp.dropone('view', 'consulta_detalle_pago_pension');
create view consulta_detalle_pago_pension as
select
    detalle_pago_pension.id,
    detalle_pago_pension.version,
    detalle_pago_pension.nombre,
    detalle_pago_pension.resumen,
    detalle_pago_pension.clase_concepto,
    detalle_pago_pension.nombre_pension,
    detalle_pago_pension.mes_planilla,
    detalle_pago_pension.ano_planilla,
    detalle_pago_pension.monto,
    detalle_pago_pension.saldo,
    detalle_pago_pension.desde,
    detalle_pago_pension.hasta,
    detalle_pago_pension.cuenta,
    detalle_pago_pension.limite,
    detalle_pago_pension.activo,
    detalle_pago_pension.fecha_inactivo,
        resumen_pago_pension_1.codigo as codigo_1,
        resumen_pago_pension_1.nombre as nombre_1,
            pension_1_1.clase as clase_1_1,
            pension_1_1.fecha_transicion as fecha_transicion_1_1,
            pension_1_1.activa as activa_1_1,
            pension_1_1.fecha_inactivar as fecha_inactivar_1_1,
            pension_1_1.segmento as segmento_1_1,
                persona_1_1_2.indigena as indigena_1_1_2,
                persona_1_1_2.icv as icv_1_1_2,
                persona_1_1_2.direccion as direccion_1_1_2,
                persona_1_1_2.telefono_linea_baja as telefono_linea_baja_1_1_2,
                persona_1_1_2.telefono_celular as telefono_celular_1_1_2,
                persona_1_1_2.edad as edad_1_1_2,
                persona_1_1_2.cuenta_bancaria as cuenta_bancaria_1_1_2,
                    sexo_persona_1_1_2_2.codigo as codigo_1_1_2_2,
                    estado_civil_1_1_2_3.codigo as codigo_1_1_2_3,
                    comunidad_indigena_1_1_2_5.nombre as nombre_1_1_2_5,
                    tipo_pobreza_1_1_2_6.codigo as codigo_1_1_2_6,
                    pais_1_1_2_7.nombre as nombre_1_1_2_7,
                    departamento_1_1_2_11.nombre as nombre_1_1_2_11,
                    distrito_1_1_2_12.nombre as nombre_1_1_2_12,
                    tipo_area_1_1_2_13.codigo as codigo_1_1_2_13,
                    banco_1_1_2_25.nombre as nombre_1_1_2_25,
                segmento_pension_1_1_19.codigo as codigo_1_1_19,
                segmento_pension_1_1_19.nombre as nombre_1_1_19,
        clase_concepto_2.codigo as codigo_2,
        clase_concepto_2.nombre as nombre_2
    from detalle_pago_pension
    inner join(resumen_pago_pension resumen_pago_pension_1
        inner join(pension pension_1_1
            inner join(persona persona_1_1_2
                left outer join sexo_persona sexo_persona_1_1_2_2 on sexo_persona_1_1_2_2.numero = persona_1_1_2.sexo
                left outer join estado_civil estado_civil_1_1_2_3 on estado_civil_1_1_2_3.numero = persona_1_1_2.estado_civil
                left outer join comunidad_indigena comunidad_indigena_1_1_2_5 on comunidad_indigena_1_1_2_5.id = persona_1_1_2.comunidad
                left outer join tipo_pobreza tipo_pobreza_1_1_2_6 on tipo_pobreza_1_1_2_6.numero = persona_1_1_2.tipo_pobreza
                left outer join pais pais_1_1_2_7 on pais_1_1_2_7.id = persona_1_1_2.pais
                inner join departamento departamento_1_1_2_11 on departamento_1_1_2_11.id = persona_1_1_2.departamento
                inner join distrito distrito_1_1_2_12 on distrito_1_1_2_12.id = persona_1_1_2.distrito
                left outer join tipo_area tipo_area_1_1_2_13 on tipo_area_1_1_2_13.numero = persona_1_1_2.tipo_area
                left outer join banco banco_1_1_2_25 on banco_1_1_2_25.id = persona_1_1_2.banco)
            on persona_1_1_2.id = pension_1_1.persona
            left outer join segmento_pension segmento_pension_1_1_19 on segmento_pension_1_1_19.id = pension_1_1.segmento)
        on pension_1_1.id = resumen_pago_pension_1.pension)
    on resumen_pago_pension_1.id = detalle_pago_pension.resumen
    inner join clase_concepto clase_concepto_2 on clase_concepto_2.id = detalle_pago_pension.clase_concepto
;
