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
exec xsp.dropone('view', 'consulta_regla_clase_pension');
create view consulta_regla_clase_pension as
select
    regla_clase_pension.id,
    regla_clase_pension.version,
    regla_clase_pension.codigo,
    regla_clase_pension.nombre,
    regla_clase_pension.clase_pension,
    regla_clase_pension.regla,
    regla_clase_pension.activo,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        regla_2.codigo as codigo_2,
        regla_2.nombre as nombre_2
    from regla_clase_pension
    inner join clase_pension clase_pension_1 on clase_pension_1.id = regla_clase_pension.clase_pension
    inner join regla regla_2 on regla_2.id = regla_clase_pension.regla
;
