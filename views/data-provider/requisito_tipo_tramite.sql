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
exec xsp.dropone('view', 'consulta_requi_tipo_tram_82289');
create view consulta_requi_tipo_tram_82289 as
select
    requisito_tipo_tramite.id,
    requisito_tipo_tramite.version,
    requisito_tipo_tramite.codigo,
    requisito_tipo_tramite.nombre,
    requisito_tipo_tramite.tipo_tramite,
    requisito_tipo_tramite.clase_requisito,
    requisito_tipo_tramite.obligatorio,
        tipo_tramite_administrativo_1.numero as numero_1,
        tipo_tramite_administrativo_1.codigo as codigo_1,
        clase_requisito_2.codigo as codigo_2,
        clase_requisito_2.nombre as nombre_2
    from requisito_tipo_tramite
    inner join tipo_tramite_administrativo tipo_tramite_administrativo_1 on tipo_tramite_administrativo_1.numero = requisito_tipo_tramite.tipo_tramite
    inner join clase_requisito clase_requisito_2 on clase_requisito_2.id = requisito_tipo_tramite.clase_requisito
;
