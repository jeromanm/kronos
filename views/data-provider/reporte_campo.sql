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
exec xsp.dropone('view', 'consulta_reporte_campo');
create view consulta_reporte_campo as
select
    reporte_campo.id,
    reporte_campo.version,
    reporte_campo.codigo,
    reporte_campo.cedula,
    reporte_campo.estado,
    reporte_campo.censista,
    reporte_campo.censo_persona,
    reporte_campo.comentario,
    reporte_campo.fecha_transicion,
    reporte_campo.numero_sime,
    reporte_campo.archivo,
    reporte_campo.linea,
    reporte_campo.informacion_invalida,
    reporte_campo.observaciones,
        censo_persona_1.codigo as codigo_1,
        carga_archivo_3.codigo as codigo_3
    from reporte_campo
    left outer join censo_persona censo_persona_1 on censo_persona_1.id = reporte_campo.censo_persona
    left outer join carga_archivo carga_archivo_3 on carga_archivo_3.id = reporte_campo.archivo
;
