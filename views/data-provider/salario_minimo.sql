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
exec xsp.dropone('view', 'consulta_salario_minimo');
create view consulta_salario_minimo as
select
    salario_minimo.id,
    salario_minimo.version,
    salario_minimo.fecha,
    salario_minimo.jornal_minimo,
    salario_minimo.salario_minimo
    from salario_minimo
;
