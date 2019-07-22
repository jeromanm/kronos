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
exec xsp.dropone('view', 'consulta_detalle_liqu_haber');
create view consulta_detalle_liqu_haber as
select
    detalle_liqu_haber.id,
    detalle_liqu_haber.version,
    detalle_liqu_haber.codigo,
    detalle_liqu_haber.liquidacion_haberes,
    detalle_liqu_haber.clase_concepto,
    detalle_liqu_haber.concepto_pension,
    detalle_liqu_haber.fecha,
    detalle_liqu_haber.monto,
    detalle_liqu_haber.tipo_movimiento,
    detalle_liqu_haber.cant_recurrente,
    detalle_liqu_haber.desde,
    detalle_liqu_haber.hasta,
    detalle_liqu_haber.proyectado,
        liquidacion_haberes_1.codigo as codigo_1,
        clase_concepto_2.codigo as codigo_2,
        clase_concepto_2.nombre as nombre_2,
        concepto_pension_3.codigo as codigo_3
    from detalle_liqu_haber
    inner join liquidacion_haberes liquidacion_haberes_1 on liquidacion_haberes_1.id = detalle_liqu_haber.liquidacion_haberes
    left outer join clase_concepto clase_concepto_2 on clase_concepto_2.id = detalle_liqu_haber.clase_concepto
    left outer join concepto_pension concepto_pension_3 on concepto_pension_3.id = detalle_liqu_haber.concepto_pension
;
