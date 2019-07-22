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
exec xsp.dropone('view', 'consulta_result_funcion_icv');
create view consulta_result_funcion_icv as
select
    result_funcion_icv.id,
    result_funcion_icv.version,
    result_funcion_icv.codigo,
    result_funcion_icv.censo_persona,
    result_funcion_icv.ficha_persona,
    result_funcion_icv.nombre,
    result_funcion_icv.resultado,
    result_funcion_icv.algoritmo,
        censo_persona_1.codigo as codigo_1,
        ficha_persona_2.codigo as codigo_2,
        ficha_persona_2.nombre as nombre_2
    from result_funcion_icv
    left outer join censo_persona censo_persona_1 on censo_persona_1.id = result_funcion_icv.censo_persona
    left outer join ficha_persona ficha_persona_2 on ficha_persona_2.id = result_funcion_icv.ficha_persona
;
