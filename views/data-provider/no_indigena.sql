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
exec xsp.dropone('view', 'consulta_no_indigena');
create view consulta_no_indigena as
select
    no_indigena.id,
    no_indigena.version,
    no_indigena.codigo,
    no_indigena.persona,
    no_indigena.cedula,
    no_indigena.nombre,
    no_indigena.nombre_entidad,
    no_indigena.numero_sime,
    no_indigena.archivo,
    no_indigena.linea,
    no_indigena.informacion_invalida,
    no_indigena.fecha_transicion,
    no_indigena.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        carga_archivo_3.codigo as codigo_3
    from no_indigena
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = no_indigena.persona
    left outer join carga_archivo carga_archivo_3 on carga_archivo_3.id = no_indigena.archivo
;
