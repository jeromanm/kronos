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
exec xsp.dropone('view', 'consulta_defuncion');
create view consulta_defuncion as
select
    defuncion.id,
    defuncion.version,
    defuncion.codigo,
    defuncion.persona,
    defuncion.cedula,
    defuncion.nombre,
    defuncion.certificado_defuncion,
    defuncion.oficina_defuncion,
    defuncion.fecha_acta_defuncion,
    defuncion.tomo_defuncion,
    defuncion.folio_defuncion,
    defuncion.acta_defuncion,
    defuncion.fecha_defuncion,
    defuncion.fecha_certificado_defuncion,
    defuncion.numero_sime,
    defuncion.departamento,
    defuncion.distrito,
    defuncion.nombre_registro,
    defuncion.lugar_fallecido,
    defuncion.nacionalidad,
    defuncion.edad,
    defuncion.lugar_nacimiento,
    defuncion.fecha_nacimiento_defu,
    defuncion.archivo,
    defuncion.linea,
    defuncion.informacion_invalida,
    defuncion.fecha_transicion,
    defuncion.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        oficina_registral_2.codigo as codigo_2,
        oficina_registral_2.nombre as nombre_2,
        departamento_4.codigo as codigo_4,
        departamento_4.nombre as nombre_4,
        distrito_5.codigo as codigo_5,
        distrito_5.nombre as nombre_5,
        carga_archivo_6.codigo as codigo_6
    from defuncion
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = defuncion.persona
    left outer join oficina_registral oficina_registral_2 on oficina_registral_2.id = defuncion.oficina_defuncion
    left outer join departamento departamento_4 on departamento_4.id = defuncion.departamento
    left outer join distrito distrito_5 on distrito_5.id = defuncion.distrito
    left outer join carga_archivo carga_archivo_6 on carga_archivo_6.id = defuncion.archivo
;
