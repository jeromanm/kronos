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
exec xsp.dropone('view', 'consulta_nacimiento');
create view consulta_nacimiento as
select
    nacimiento.id,
    nacimiento.version,
    nacimiento.codigo,
    nacimiento.persona,
    nacimiento.cedula,
    nacimiento.nombre,
    nacimiento.fecha_nacimientos,
    nacimiento.departamento_nacimiento,
    nacimiento.distrito_nacimiento,
    nacimiento.personamadre,
    nacimiento.cedula_madre,
    nacimiento.nombre_madre,
    nacimiento.personapadre,
    nacimiento.cedula_padre,
    nacimiento.nombre_padre,
    nacimiento.folio_nacimiento,
    nacimiento.acta_nacimiento,
    nacimiento.tomo_nacimiento,
    nacimiento.archivo,
    nacimiento.linea,
    nacimiento.fecha_transicion,
    nacimiento.numero_sime,
    nacimiento.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        departamento_2.codigo as codigo_2,
        departamento_2.nombre as nombre_2,
        distrito_3.codigo as codigo_3,
        distrito_3.nombre as nombre_3,
        persona_4.codigo as codigo_4,
        persona_4.nombre as nombre_4,
        persona_5.codigo as codigo_5,
        persona_5.nombre as nombre_5,
        carga_archivo_6.codigo as codigo_6
    from nacimiento
    left outer join persona persona_1 on persona_1.id = nacimiento.persona
    inner join departamento departamento_2 on departamento_2.id = nacimiento.departamento_nacimiento
    inner join distrito distrito_3 on distrito_3.id = nacimiento.distrito_nacimiento
    left outer join persona persona_4 on persona_4.id = nacimiento.personamadre
    left outer join persona persona_5 on persona_5.id = nacimiento.personapadre
    left outer join carga_archivo carga_archivo_6 on carga_archivo_6.id = nacimiento.archivo
;
