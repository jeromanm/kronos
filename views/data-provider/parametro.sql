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
exec xsp.dropone('view', 'consulta_parametro');
create view consulta_parametro as
select
    parametro.id_parametro,
    parametro.version_parametro,
    parametro.codigo_parametro,
    parametro.nombre_parametro,
    parametro.detalle_parametro,
    parametro.descripcion_parametro,
    parametro.numero_tipo_dato_par,
    parametro.clase_java,
    parametro.anulable,
    parametro.longitud,
    parametro.precision,
    parametro.escala,
    parametro.pixeles,
        tipo_dato_par_1.numero_tipo_dato_par as numero_tipo_dato_par_1,
        tipo_dato_par_1.codigo_tipo_dato_par as codigo_tipo_dato_par_1,
        clase_java_2.numero as numero_2,
        clase_java_2.codigo as codigo_2
    from parametro
    inner join tipo_dato_par tipo_dato_par_1 on tipo_dato_par_1.numero_tipo_dato_par = parametro.numero_tipo_dato_par
    inner join clase_java clase_java_2 on clase_java_2.numero = parametro.clase_java
;
