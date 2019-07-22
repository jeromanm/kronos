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
exec xsp.dropone('view', 'consulta_clase_pension_comp');
create view consulta_clase_pension_comp as
select
    clase_pension_comp.id,
    clase_pension_comp.version,
    clase_pension_comp.codigo,
    clase_pension_comp.clase,
    clase_pension_comp.clase_comp,
    clase_pension_comp.compatible,
    clase_pension_comp.restringido,
    clase_pension_comp.observaciones,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        clase_pension_2.codigo as codigo_2,
        clase_pension_2.nombre as nombre_2
    from clase_pension_comp
    inner join clase_pension clase_pension_1 on clase_pension_1.id = clase_pension_comp.clase
    inner join clase_pension clase_pension_2 on clase_pension_2.id = clase_pension_comp.clase_comp
;
