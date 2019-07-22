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
exec xsp.dropone('view', 'consulta_acuerdo_pago');
create view consulta_acuerdo_pago as
select
    acuerdo_pago.id,
    acuerdo_pago.version,
    acuerdo_pago.codigo,
    acuerdo_pago.persona,
    acuerdo_pago.pension,
    acuerdo_pago.fecha,
    acuerdo_pago.monto,
    acuerdo_pago.cuota,
    acuerdo_pago.saldo,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        pension_2.codigo as codigo_2,
        pension_2.segmento as segmento_2,
            segmento_pension_2_19.codigo as codigo_2_19,
            segmento_pension_2_19.nombre as nombre_2_19
    from acuerdo_pago
    inner join persona persona_1 on persona_1.id = acuerdo_pago.persona
    inner join(pension pension_2
        left outer join segmento_pension segmento_pension_2_19 on segmento_pension_2_19.id = pension_2.segmento)
    on pension_2.id = acuerdo_pago.pension
;
