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
exec xsp.dropone('view', 'consulta_deta_cobr_indeb_72284');
create view consulta_deta_cobr_indeb_72284 as
select
    detalle_cobro_indebido.id,
    detalle_cobro_indebido.version,
    detalle_cobro_indebido.codigo,
    detalle_cobro_indebido.resumen,
    detalle_cobro_indebido.clase_concepto,
    detalle_cobro_indebido.monto_indebido,
    detalle_cobro_indebido.saldo_indebido,
    detalle_cobro_indebido.desde,
    detalle_cobro_indebido.hasta,
    detalle_cobro_indebido.cuenta,
    detalle_cobro_indebido.limite,
        resumen_pago_pension_1.codigo as codigo_1,
        resumen_pago_pension_1.nombre as nombre_1,
            pension_1_1.segmento as segmento_1_1,
                segmento_pension_1_1_19.codigo as codigo_1_1_19,
                segmento_pension_1_1_19.nombre as nombre_1_1_19,
        clase_concepto_2.codigo as codigo_2,
        clase_concepto_2.nombre as nombre_2
    from detalle_cobro_indebido
    inner join(resumen_pago_pension resumen_pago_pension_1
        inner join(pension pension_1_1
            left outer join segmento_pension segmento_pension_1_1_19 on segmento_pension_1_1_19.id = pension_1_1.segmento)
        on pension_1_1.id = resumen_pago_pension_1.pension)
    on resumen_pago_pension_1.id = detalle_cobro_indebido.resumen
    inner join clase_concepto clase_concepto_2 on clase_concepto_2.id = detalle_cobro_indebido.clase_concepto
;
