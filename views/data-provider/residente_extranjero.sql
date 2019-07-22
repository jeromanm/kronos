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
exec xsp.dropone('view', 'consulta_residente_extranjero');
create view consulta_residente_extranjero as
select
    residente_extranjero.id,
    residente_extranjero.version,
    residente_extranjero.codigo,
    residente_extranjero.persona,
    residente_extranjero.cedula,
    residente_extranjero.nombre,
    residente_extranjero.ano_votacion,
    residente_extranjero.pais,
    residente_extranjero.domicilio,
    residente_extranjero.fecha_inscripcion,
    residente_extranjero.archivo,
    residente_extranjero.linea,
    residente_extranjero.informacion_invalida,
    residente_extranjero.fecha_transicion,
    residente_extranjero.numero_sime,
    residente_extranjero.descripcion,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        pais_2.codigo as codigo_2,
        pais_2.nombre as nombre_2,
        carga_archivo_3.codigo as codigo_3
    from residente_extranjero
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = residente_extranjero.persona
    left outer join pais pais_2 on pais_2.id = residente_extranjero.pais
    left outer join carga_archivo carga_archivo_3 on carga_archivo_3.id = residente_extranjero.archivo
;
