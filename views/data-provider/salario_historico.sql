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
exec xsp.dropone('view', 'consulta_salario_historico');
create view consulta_salario_historico as
select
    salario_historico.id,
    salario_historico.version,
    salario_historico.codigo,
    salario_historico.clase_pension,
    salario_historico.clase_concepto,
    salario_historico.fecha_desde,
    salario_historico.fecha_hasta,
    salario_historico.monto,
    salario_historico.fecha_nacimiento,
        clase_pension_1.codigo as codigo_1,
        clase_pension_1.nombre as nombre_1,
        clase_concepto_2.codigo as codigo_2,
        clase_concepto_2.nombre as nombre_2
    from salario_historico
    inner join clase_pension clase_pension_1 on clase_pension_1.id = salario_historico.clase_pension
    inner join clase_concepto clase_concepto_2 on clase_concepto_2.id = salario_historico.clase_concepto
;
