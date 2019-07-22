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
exec xsp.dropone('view', 'consulta_grupo_proceso');
create view consulta_grupo_proceso as
select
    grupo_proceso.id_grupo_proceso,
    grupo_proceso.version_grupo_proceso,
    grupo_proceso.codigo_grupo_proceso,
    grupo_proceso.nombre_grupo_proceso,
    grupo_proceso.descripcion_grupo_proceso,
    grupo_proceso.id_rastro_proceso,
    grupo_proceso.numero_condicion_eje_fun,
        condicion_eje_fun_1.numero_condicion_eje_fun as numero_condicion_eje_fun_1,
        condicion_eje_fun_1.codigo_condicion_eje_fun as codigo_condicion_eje_fun_1
    from grupo_proceso
    left outer join condicion_eje_fun condicion_eje_fun_1 on condicion_eje_fun_1.numero_condicion_eje_fun = grupo_proceso.numero_condicion_eje_fun
;
