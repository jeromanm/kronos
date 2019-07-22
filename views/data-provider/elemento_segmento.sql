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
exec xsp.dropone('view', 'consulta_elemento_segmento');
create view consulta_elemento_segmento as
select
    elemento_segmento.id_elemento_segmento,
    elemento_segmento.version_elemento_segmento,
    elemento_segmento.segmento,
    elemento_segmento.segmento_entero_grande,
    elemento_segmento.id_segmento,
    elemento_segmento.codigo_segmento,
    elemento_segmento.nombre_segmento,
    elemento_segmento.id_conjunto_segmento,
        conjunto_segmento_2.codigo_conjunto_segmento as codigo_conjunto_segmento_2,
        conjunto_segmento_2.nombre_conjunto_segmento as nombre_conjunto_segmento_2
    from elemento_segmento
    inner join conjunto_segmento conjunto_segmento_2 on conjunto_segmento_2.id_conjunto_segmento = elemento_segmento.id_conjunto_segmento
;
