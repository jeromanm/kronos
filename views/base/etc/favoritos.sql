/*
 * Este programa es software libre; usted puede redistribuirlo y/o modificarlo bajo los terminos
 * de la licencia "GNU General Public License" publicada por la Fundacion "Free Software Foundation".
 * Este programa se distribuye con la esperanza de que pueda ser util, pero SIN NINGUNA GARANTIA;
 * vea la licencia "GNU General Public License" para obtener mas informacion.
 */
/*
 * author: Jorge Campins
 */
exec xsp.dropone('view', 'favoritos');
create view favoritos as
select
        pagina_usuario.id_pagina_usuario,
        pagina_usuario.version_pagina_usuario,
        pagina_usuario.id_pagina,
        pagina_usuario.id_usuario,
        pagina.codigo_pagina,
        pagina.nombre_pagina,
        pagina.id_aplicacion,
        pagina.numero_tipo_pagina,
        pagina.url_pagina,
        usuario.codigo_usuario,
        usuario.nombre_usuario,
        aplicacion.url_aplicacion,
        clase_recurso.id_clase_recurso,
        clase_recurso.numero_tipo_recurso--,
--      case
--          when clase_recurso.id_grupo_aplicacion is null
--          then aplicacion.id_grupo_aplicacion
--          else clase_recurso.id_grupo_aplicacion
--      end as id_grupo_aplicacion
from    pagina_usuario
        inner join pagina
            on pagina.id_pagina = pagina_usuario.id_pagina
        inner join usuario
            on usuario.id_usuario = pagina_usuario.id_usuario
        inner join aplicacion
            on aplicacion.id_aplicacion = pagina.id_aplicacion
        left outer join (dominio
            inner join clase_recurso on clase_recurso.id_clase_recurso = dominio.id_clase_recurso
        ) on dominio.id_dominio = pagina.id_dominio
;
