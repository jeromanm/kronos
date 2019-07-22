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
exec xsp.dropone('view', 'consulta_estado_cuenta');
create view consulta_estado_cuenta as
select
    estado_cuenta.id,
    estado_cuenta.version,
    estado_cuenta.codigo,
    estado_cuenta.persona,
    estado_cuenta.fecha,
    estado_cuenta.debitos,
    estado_cuenta.creditos,
    estado_cuenta.saldo_final,
    estado_cuenta.numero_sime,
    estado_cuenta.archivo,
    estado_cuenta.linea,
    estado_cuenta.informacion_invalida,
    estado_cuenta.fecha_transicion,
    estado_cuenta.observaciones,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        persona_1.distrito as distrito_1,
            distrito_1_12.codigo as codigo_1_12,
            distrito_1_12.nombre as nombre_1_12,
        carga_archivo_3.codigo as codigo_3
    from estado_cuenta
    inner join(persona persona_1
        inner join distrito distrito_1_12 on distrito_1_12.id = persona_1.distrito)
    on persona_1.id = estado_cuenta.persona
    left outer join carga_archivo carga_archivo_3 on carga_archivo_3.id = estado_cuenta.archivo
;
