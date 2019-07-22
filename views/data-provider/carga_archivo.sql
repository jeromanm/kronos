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
exec xsp.dropone('view', 'consulta_carga_archivo');
create view consulta_carga_archivo as
select
    carga_archivo.id,
    carga_archivo.version,
    carga_archivo.codigo,
    carga_archivo.clase,
    carga_archivo.archivo,
    carga_archivo.adjunto,
    carga_archivo.numero_sime,
    expediente_sime_3.numero as numero_sime_nro,
    expediente_sime_3.ary as numero_sime_ano,
    carga_archivo.fecha_hora,
    carga_archivo.archivo_sin_errores,
    carga_archivo.proceso_sin_errores,
    carga_archivo.observaciones,
    carga_archivo.directorio,
    carga_archivo.ultimo_registro,
        clase_archivo_1.codigo as codigo_1,
        clase_archivo_1.nombre as nombre_1,
        archivo_adjunto_2.archivo_servidor as archivo_servidor_2,
        archivo_adjunto_2.archivo_cliente as archivo_cliente_2,
        expediente_sime_3.numero as numero_3,
        expediente_sime_3.ary as ary_3
    from carga_archivo
    inner join clase_archivo clase_archivo_1 on clase_archivo_1.id = carga_archivo.clase
    left outer join archivo_adjunto archivo_adjunto_2 on archivo_adjunto_2.id = carga_archivo.adjunto
    left outer join expediente_sime expediente_sime_3 on expediente_sime_3.id = carga_archivo.numero_sime
;
