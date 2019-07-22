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
exec xsp.dropone('view', 'consulta_solicitud_cuenta');
create view consulta_solicitud_cuenta as
select
    solicitud_cuenta.id,
    solicitud_cuenta.version,
    solicitud_cuenta.codigo,
    solicitud_cuenta.nro_solicitud,
    solicitud_cuenta.cedula,
    solicitud_cuenta.fecha_solicitud,
    solicitud_cuenta.fecha_respuesta,
    solicitud_cuenta.banco,
    solicitud_cuenta.cuenta_bancaria,
    solicitud_cuenta.descripcion,
        encabezado_solicitud_1.codigo as codigo_1,
        banco_2.codigo as codigo_2,
        banco_2.nombre as nombre_2
    from solicitud_cuenta
    left outer join encabezado_solicitud encabezado_solicitud_1 on encabezado_solicitud_1.id = solicitud_cuenta.nro_solicitud
    left outer join banco banco_2 on banco_2.id = solicitud_cuenta.banco
;
