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
exec xsp.dropone('view', 'consulta_linea_archivo');
create view consulta_linea_archivo as
select
    linea_archivo.id,
    linea_archivo.version,
    linea_archivo.codigo,
    linea_archivo.carga,
    linea_archivo.numero,
    linea_archivo.texto,
    linea_archivo.errores,
        carga_archivo_1.codigo as codigo_1
    from linea_archivo
    inner join carga_archivo carga_archivo_1 on carga_archivo_1.id = linea_archivo.carga
;
