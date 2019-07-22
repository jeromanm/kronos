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
exec xsp.dropone('view', 'consulta_segmento_pension');
create view consulta_segmento_pension as
select
    segmento_pension.id,
    segmento_pension.version,
    segmento_pension.codigo,
    segmento_pension.nombre,
    segmento_pension.grupo,
    segmento_pension.distrito,
        grupo_pension_1.codigo as codigo_1,
        grupo_pension_1.nombre as nombre_1,
        distrito_2.codigo as codigo_2,
        distrito_2.nombre as nombre_2
    from segmento_pension
    inner join grupo_pension grupo_pension_1 on grupo_pension_1.id = segmento_pension.grupo
    inner join distrito distrito_2 on distrito_2.id = segmento_pension.distrito
;
