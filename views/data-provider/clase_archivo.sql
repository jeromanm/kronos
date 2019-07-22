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
exec xsp.dropone('view', 'consulta_clase_archivo');
create view consulta_clase_archivo as
select
    clase_archivo.id,
    clase_archivo.version,
    clase_archivo.codigo,
    clase_archivo.nombre,
    clase_archivo.descripcion,
    clase_archivo.tipo,
    clase_archivo.fuente,
    clase_archivo.tipo_carga,
        tipo_archivo_1.numero as numero_1,
        tipo_archivo_1.codigo as codigo_1,
        fuente_archivo_2.codigo as codigo_2,
        fuente_archivo_2.nombre as nombre_2,
        tipo_carga_archivo_3.numero as numero_3,
        tipo_carga_archivo_3.codigo as codigo_3
    from clase_archivo
    inner join tipo_archivo tipo_archivo_1 on tipo_archivo_1.numero = clase_archivo.tipo
    inner join fuente_archivo fuente_archivo_2 on fuente_archivo_2.id = clase_archivo.fuente
    inner join tipo_carga_archivo tipo_carga_archivo_3 on tipo_carga_archivo_3.numero = clase_archivo.tipo_carga
;
