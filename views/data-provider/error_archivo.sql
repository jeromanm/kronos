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
exec xsp.dropone('view', 'consulta_error_archivo');
create view consulta_error_archivo as
select
    error_archivo.id,
    error_archivo.version,
    error_archivo.codigo,
    error_archivo.linea,
    error_archivo.tipo,
    error_archivo.descripcion,
        linea_archivo_1.codigo as codigo_1,
        linea_archivo_1.numero as numero_1,
            carga_archivo_1_1.archivo as archivo_1_1,
            carga_archivo_1_1.fecha_hora as fecha_hora_1_1,
                clase_archivo_1_1_1.nombre as nombre_1_1_1,
                    fuente_archivo_1_1_1_2.nombre as nombre_1_1_1_2,
        tipo_error_archivo_2.numero as numero_2,
        tipo_error_archivo_2.codigo as codigo_2
    from error_archivo
    inner join(linea_archivo linea_archivo_1
        inner join(carga_archivo carga_archivo_1_1
            inner join(clase_archivo clase_archivo_1_1_1
                inner join fuente_archivo fuente_archivo_1_1_1_2 on fuente_archivo_1_1_1_2.id = clase_archivo_1_1_1.fuente)
            on clase_archivo_1_1_1.id = carga_archivo_1_1.clase)
        on carga_archivo_1_1.id = linea_archivo_1.carga)
    on linea_archivo_1.id = error_archivo.linea
    inner join tipo_error_archivo tipo_error_archivo_2 on tipo_error_archivo_2.numero = error_archivo.tipo
;
