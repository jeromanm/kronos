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
exec xsp.dropone('view', 'consulta_matrimonio');
create view consulta_matrimonio as
select
    matrimonio.id,
    matrimonio.version,
    matrimonio.codigo,
    matrimonio.persona,
    matrimonio.cedula1,
    matrimonio.nombre1,
    matrimonio.certificado_matrimonio,
    matrimonio.oficina_matrimonio,
    matrimonio.fecha_acta_matrimonio,
    matrimonio.tomo_matrimonio,
    matrimonio.folio_matrimonio,
    matrimonio.acta_matrimonio,
    matrimonio.persona2,
    matrimonio.cedula2,
    matrimonio.nombre2,
    matrimonio.fecha_matrimonio,
    matrimonio.fecha_certificado_matrimonio,
    matrimonio.numero_sime,
    matrimonio.archivo,
    matrimonio.linea,
    matrimonio.informacion_invalida,
    matrimonio.fecha_transicion,
    matrimonio.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        oficina_registral_2.codigo as codigo_2,
        oficina_registral_2.nombre as nombre_2,
        persona_3.codigo as codigo_3,
        persona_3.nombre as nombre_3,
        carga_archivo_5.codigo as codigo_5
    from matrimonio
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = matrimonio.persona
    left outer join oficina_registral oficina_registral_2 on oficina_registral_2.id = matrimonio.oficina_matrimonio
    left outer join persona persona_3 on persona_3.id = matrimonio.persona2
    left outer join carga_archivo carga_archivo_5 on carga_archivo_5.id = matrimonio.archivo
;
