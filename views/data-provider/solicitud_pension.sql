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
exec xsp.dropone('view', 'consulta_solicitud_pension');
create view consulta_solicitud_pension as
select
    solicitud_pension.id,
    solicitud_pension.version,
    solicitud_pension.codigo,
    solicitud_pension.cedula,
    solicitud_pension.nombre,
    solicitud_pension.persona,
    solicitud_pension.pension,
    solicitud_pension.censo_persona,
    solicitud_pension.ficha_persona,
    solicitud_pension.departamento,
    solicitud_pension.distrito,
    solicitud_pension.fecha_transicion,
    solicitud_pension.numero_sime,
    solicitud_pension.archivo,
    solicitud_pension.linea,
    solicitud_pension.informacion_invalida,
    solicitud_pension.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        pension_2.codigo as codigo_2,
        censo_persona_3.codigo as codigo_3,
        ficha_persona_4.codigo as codigo_4,
        ficha_persona_4.nombre as nombre_4,
        departamento_5.codigo as codigo_5,
        departamento_5.nombre as nombre_5,
        distrito_6.codigo as codigo_6,
        distrito_6.nombre as nombre_6,
        carga_archivo_8.codigo as codigo_8
    from solicitud_pension
    left outer join persona persona_1 on persona_1.id = solicitud_pension.persona
    left outer join pension pension_2 on pension_2.id = solicitud_pension.pension
    left outer join censo_persona censo_persona_3 on censo_persona_3.id = solicitud_pension.censo_persona
    left outer join ficha_persona ficha_persona_4 on ficha_persona_4.id = solicitud_pension.ficha_persona
    left outer join departamento departamento_5 on departamento_5.id = solicitud_pension.departamento
    left outer join distrito distrito_6 on distrito_6.id = solicitud_pension.distrito
    left outer join carga_archivo carga_archivo_8 on carga_archivo_8.id = solicitud_pension.archivo
;
