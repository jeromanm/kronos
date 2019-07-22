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
exec xsp.dropone('view', 'consulta_cotizante');
create view consulta_cotizante as
select
    cotizante.id,
    cotizante.version,
    cotizante.codigo,
    cotizante.persona,
    cotizante.cedula,
    cotizante.nombre,
    cotizante.fecha_ingreso_cotizante,
    cotizante.fecha_egreso_cotizante,
    cotizante.monto_cotizante,
    cotizante.nombres_empresa,
    cotizante.ruc,
    cotizante.archivo,
    cotizante.linea,
    cotizante.fecha_transicion,
    cotizante.numero_sime,
    cotizante.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        carga_archivo_2.codigo as codigo_2
    from cotizante
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = cotizante.persona
    left outer join carga_archivo carga_archivo_2 on carga_archivo_2.id = cotizante.archivo
;
