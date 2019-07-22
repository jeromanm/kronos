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
exec xsp.dropone('view', 'consulta_dominio_parametro');
create view consulta_dominio_parametro as
select
    dominio_parametro.id_dominio_parametro,
    dominio_parametro.version_dominio_parametro,
    dominio_parametro.codigo_dominio_parametro,
    dominio_parametro.columna,
    dominio_parametro.alias,
    dominio_parametro.etiqueta_parametro,
    dominio_parametro.id_dominio,
    dominio_parametro.id_parametro,
    dominio_parametro.numero_tipo_parametro_dom,
        dominio_1.codigo_dominio as codigo_dominio_1,
        dominio_1.nombre_dominio as nombre_dominio_1,
        parametro_2.codigo_parametro as codigo_parametro_2,
        parametro_2.nombre_parametro as nombre_parametro_2,
        tipo_parametro_dom_3.numero_tipo_parametro_dom as numero_tipo_parametro_dom_3,
        tipo_parametro_dom_3.codigo_tipo_parametro_dom as codigo_tipo_parametro_dom_3
    from dominio_parametro
    inner join dominio dominio_1 on dominio_1.id_dominio = dominio_parametro.id_dominio
    inner join parametro parametro_2 on parametro_2.id_parametro = dominio_parametro.id_parametro
    inner join tipo_parametro_dom tipo_parametro_dom_3 on tipo_parametro_dom_3.numero_tipo_parametro_dom = dominio_parametro.numero_tipo_parametro_dom
;
