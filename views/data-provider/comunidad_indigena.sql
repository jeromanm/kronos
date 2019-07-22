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
exec xsp.dropone('view', 'consulta_comunidad_indigena');
create view consulta_comunidad_indigena as
select
    comunidad_indigena.id,
    comunidad_indigena.version,
    comunidad_indigena.codigo,
    comunidad_indigena.nombre,
    comunidad_indigena.etnia,
        etnia_indigena_1.codigo as codigo_1,
        etnia_indigena_1.nombre as nombre_1
    from comunidad_indigena
    inner join etnia_indigena etnia_indigena_1 on etnia_indigena_1.id = comunidad_indigena.etnia
;
