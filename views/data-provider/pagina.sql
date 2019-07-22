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
exec xsp.dropone('view', 'consulta_pagina');
create view consulta_pagina as
select
    pagina.id_pagina,
    pagina.version_pagina,
    pagina.codigo_pagina,
    pagina.nombre_pagina,
    pagina.descripcion_pagina,
    pagina.url_pagina,
    pagina.es_publica,
    pagina.es_especial,
    pagina.id_aplicacion,
    pagina.numero_tipo_pagina,
    pagina.id_dominio,
    pagina.id_dominio_maestro,
    pagina.id_parametro,
        aplicacion_1.codigo_aplicacion as codigo_aplicacion_1,
        aplicacion_1.nombre_aplicacion as nombre_aplicacion_1,
        tipo_pagina_2.numero_tipo_pagina as numero_tipo_pagina_2,
        tipo_pagina_2.codigo_tipo_pagina as codigo_tipo_pagina_2,
        dominio_3.codigo_dominio as codigo_dominio_3,
        dominio_3.nombre_dominio as nombre_dominio_3,
        dominio_4.codigo_dominio as codigo_dominio_4,
        dominio_4.nombre_dominio as nombre_dominio_4,
        parametro_5.codigo_parametro as codigo_parametro_5,
        parametro_5.nombre_parametro as nombre_parametro_5
    from pagina
    inner join aplicacion aplicacion_1 on aplicacion_1.id_aplicacion = pagina.id_aplicacion
    left outer join tipo_pagina tipo_pagina_2 on tipo_pagina_2.numero_tipo_pagina = pagina.numero_tipo_pagina
    left outer join dominio dominio_3 on dominio_3.id_dominio = pagina.id_dominio
    left outer join dominio dominio_4 on dominio_4.id_dominio = pagina.id_dominio_maestro
    left outer join parametro parametro_5 on parametro_5.id_parametro = pagina.id_parametro
;
