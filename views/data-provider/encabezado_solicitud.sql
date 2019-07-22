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
exec xsp.dropone('view', 'consulta_encabezado_solicitud');
create view consulta_encabezado_solicitud as
select
    encabezado_solicitud.id,
    encabezado_solicitud.version,
    encabezado_solicitud.codigo,
    encabezado_solicitud.tipo_alta,
    encabezado_solicitud.edad_desde,
    encabezado_solicitud.edad_hasta,
    encabezado_solicitud.clase_pension_desde,
    encabezado_solicitud.clase_pension_hasta,
    encabezado_solicitud.fecha_solicitud,
    encabezado_solicitud.fecha_respuesta,
    encabezado_solicitud.estado_solicitud,
    encabezado_solicitud.nen_codigo,
    encabezado_solicitud.ent_codigo,
    encabezado_solicitud.descripcion,
    encabezado_solicitud.fallecido,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        clase_pension_2.codigo as codigo_2,
        clase_pension_2.nombre as nombre_2,
        estado_solicitud_3.numero as numero_3,
        estado_solicitud_3.codigo as codigo_3
    from encabezado_solicitud
    left outer join clase_pension clase_pension_1 on clase_pension_1.id = encabezado_solicitud.clase_pension_desde
    left outer join clase_pension clase_pension_2 on clase_pension_2.id = encabezado_solicitud.clase_pension_hasta
    inner join estado_solicitud estado_solicitud_3 on estado_solicitud_3.numero = encabezado_solicitud.estado_solicitud
;
