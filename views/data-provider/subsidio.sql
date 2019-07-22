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
exec xsp.dropone('view', 'consulta_subsidio');
create view consulta_subsidio as
select
    subsidio.id,
    subsidio.version,
    subsidio.codigo,
    subsidio.persona,
    subsidio.cedula,
    subsidio.nombre,
    subsidio.fecha_ingreso,
    subsidio.fecha_egreso,
    subsidio.monto,
    subsidio.nombre_empresa,
    subsidio.numero_sime,
    subsidio.archivo,
    subsidio.linea,
    subsidio.informacion_invalida,
    subsidio.fecha_transicion,
    subsidio.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        carga_archivo_3.codigo as codigo_3
    from subsidio
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = subsidio.persona
    left outer join carga_archivo carga_archivo_3 on carga_archivo_3.id = subsidio.archivo
;
