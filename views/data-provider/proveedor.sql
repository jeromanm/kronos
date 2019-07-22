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
exec xsp.dropone('view', 'consulta_proveedor');
create view consulta_proveedor as
select
    proveedor.id,
    proveedor.version,
    proveedor.codigo,
    proveedor.persona,
    proveedor.cedula,
    proveedor.nombre,
    proveedor.tipo_proveedor,
    proveedor.ruc_entidad,
    proveedor.denominacion_entidad,
    proveedor.archivo,
    proveedor.linea,
    proveedor.fecha_transicion,
    proveedor.numero_sime,
    proveedor.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        tipo_persona_2.numero as numero_2,
        tipo_persona_2.codigo as codigo_2,
        carga_archivo_3.codigo as codigo_3
    from proveedor
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = proveedor.persona
    left outer join tipo_persona tipo_persona_2 on tipo_persona_2.numero = proveedor.tipo_proveedor
    left outer join carga_archivo carga_archivo_3 on carga_archivo_3.id = proveedor.archivo
;
