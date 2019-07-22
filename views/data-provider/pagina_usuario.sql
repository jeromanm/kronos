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
exec xsp.dropone('view', 'consulta_pagina_usuario');
create view consulta_pagina_usuario as
select
    pagina_usuario.id_pagina_usuario,
    pagina_usuario.version_pagina_usuario,
    pagina_usuario.id_pagina,
    pagina_usuario.id_usuario,
        pagina_1.codigo_pagina as codigo_pagina_1,
        pagina_1.nombre_pagina as nombre_pagina_1,
        usuario_2.codigo_usuario as codigo_usuario_2,
        usuario_2.nombre_usuario as nombre_usuario_2
    from pagina_usuario
    left outer join pagina pagina_1 on pagina_1.id_pagina = pagina_usuario.id_pagina
    inner join usuario usuario_2 on usuario_2.id_usuario = pagina_usuario.id_usuario
;
