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
exec xsp.dropone('view', 'consulta_rol_pagina');
create view consulta_rol_pagina as
select
    rol_pagina.id_rol_pagina,
    rol_pagina.version_rol_pagina,
    rol_pagina.id_rol,
    rol_pagina.id_pagina,
        rol_1.codigo_rol as codigo_rol_1,
        rol_1.nombre_rol as nombre_rol_1,
        pagina_2.codigo_pagina as codigo_pagina_2,
        pagina_2.nombre_pagina as nombre_pagina_2
    from rol_pagina
    inner join rol rol_1 on rol_1.id_rol = rol_pagina.id_rol
    left outer join pagina pagina_2 on pagina_2.id_pagina = rol_pagina.id_pagina
;
