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
exec xsp.dropone('view', 'consulta_senacsa');
create view consulta_senacsa as
select
    senacsa.id,
    senacsa.version,
    senacsa.codigo,
    senacsa.persona,
    senacsa.cedula,
    senacsa.nombre,
    senacsa.estancia,
    senacsa.fecha_ingreso_senacsa,
    senacsa.fecha_egreso_senacsa,
    senacsa.tipo_senacsa,
    senacsa.cantidad_senacsa,
    senacsa.monto_senacsa,
    senacsa.archivo,
    senacsa.linea,
    senacsa.fecha_transicion,
    senacsa.numero_sime_senacsa,
    senacsa.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        carga_archivo_2.codigo as codigo_2
    from senacsa
    left outer join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = senacsa.persona
    left outer join carga_archivo carga_archivo_2 on carga_archivo_2.id = senacsa.archivo
;
