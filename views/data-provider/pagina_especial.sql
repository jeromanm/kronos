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
exec xsp.dropone('view', 'consulta_pagina_especial');
create view consulta_pagina_especial as
select
    pagina_especial.id,
    pagina_especial.version,
    pagina_especial.codigo,
    pagina_especial.descripcion,
    pagina_especial.uri,
    pagina_especial.publica,
    pagina_especial.inactiva
    from pagina_especial
;
