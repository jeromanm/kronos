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
exec xsp.dropone('view', 'consulta_pago_acuerdo_pension');
create view consulta_pago_acuerdo_pension as
select
    pago_acuerdo_pension.id,
    pago_acuerdo_pension.version,
    pago_acuerdo_pension.codigo,
    pago_acuerdo_pension.pension,
    pago_acuerdo_pension.numero_sime,
    pago_acuerdo_pension.fecha,
    pago_acuerdo_pension.monto,
    pago_acuerdo_pension.boleta,
    pago_acuerdo_pension.acuerdo_pago,
        pension_1.codigo as codigo_1,
        pension_1.saldo_inicial as saldo_inicial_1,
        pension_1.saldo_actual as saldo_actual_1,
        pension_1.monto_pagado as monto_pagado_1,
        pension_1.cant_planilla_exceso as cant_planilla_exceso_1,
        pension_1.monto_reintegro as monto_reintegro_1,
        pension_1.monto_deuda as monto_deuda_1,
        pension_1.monto_cuota as monto_cuota_1,
        pension_1.saldo_deudor as saldo_deudor_1,
        pension_1.segmento as segmento_1,
            persona_1_2.cedula as cedula_1_2,
            persona_1_2.nombres as nombres_1_2,
            persona_1_2.fecha_ingreso as fecha_ingreso_1_2,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        acuerdo_pago_3.codigo as codigo_3
    from pago_acuerdo_pension
    inner join(pension pension_1
        inner join persona persona_1_2 on persona_1_2.id = pension_1.persona
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = pago_acuerdo_pension.pension
    left outer join acuerdo_pago acuerdo_pago_3 on acuerdo_pago_3.id = pago_acuerdo_pension.acuerdo_pago
;
