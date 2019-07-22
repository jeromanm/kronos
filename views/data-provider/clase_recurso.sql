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
exec xsp.dropone('view', 'consulta_clase_recurso');
create view consulta_clase_recurso as
select
    clase_recurso.id_clase_recurso,
    clase_recurso.version_clase_recurso,
    clase_recurso.codigo_clase_recurso,
    clase_recurso.nombre_clase_recurso,
    clase_recurso.descripcion_clase_recurso,
    clase_recurso.paquete_clase_recurso,
    clase_recurso.es_clase_recurso_independiente,
    clase_recurso.es_clase_recurso_sin_detalle,
    clase_recurso.es_clase_recurso_con_arbol,
    clase_recurso.es_clase_recurso_segmento,
    clase_recurso.limite_filas_consulta,
    clase_recurso.limite_filas_informe,
    clase_recurso.orden_presentacion,
    clase_recurso.es_clase_recurso_insertable,
    clase_recurso.es_clase_recurso_modificable,
    clase_recurso.es_clase_recurso_eliminable,
    clase_recurso.es_clase_recurso_extendida,
    clase_recurso.etiqueta_hipervinculo,
    clase_recurso.es_enumerador_con_numero,
    clase_recurso.numero_tipo_clase_recurso,
    clase_recurso.numero_tipo_recurso,
    clase_recurso.id_funcion_seleccion,
    clase_recurso.id_pagina_seleccion,
    clase_recurso.id_pagina_detalle,
    clase_recurso.id_pagina_funcion,
    clase_recurso.pagina_seleccion,
    clase_recurso.pagina_detalle,
    clase_recurso.pagina_funcion,
    clase_recurso.id_clase_recurso_maestro,
    clase_recurso.id_clase_recurso_segmento,
    clase_recurso.id_clase_recurso_base,
        tipo_clase_recurso_1.numero_tipo_clase_recurso as numero_tipo_clase_recurso_1,
        tipo_clase_recurso_1.codigo_tipo_clase_recurso as codigo_tipo_clase_recurso_1,
        tipo_recurso_2.numero_tipo_recurso as numero_tipo_recurso_2,
        tipo_recurso_2.codigo_tipo_recurso as codigo_tipo_recurso_2,
        funcion_3.codigo_funcion as codigo_funcion_3,
        funcion_3.nombre_funcion as nombre_funcion_3,
        pagina_4.codigo_pagina as codigo_pagina_4,
        pagina_4.nombre_pagina as nombre_pagina_4,
        pagina_5.codigo_pagina as codigo_pagina_5,
        pagina_5.nombre_pagina as nombre_pagina_5,
        pagina_6.codigo_pagina as codigo_pagina_6,
        pagina_6.nombre_pagina as nombre_pagina_6,
        clase_recurso_7.codigo_clase_recurso as codigo_clase_recurso_7,
        clase_recurso_7.nombre_clase_recurso as nombre_clase_recurso_7,
        clase_recurso_8.codigo_clase_recurso as codigo_clase_recurso_8,
        clase_recurso_8.nombre_clase_recurso as nombre_clase_recurso_8,
        clase_recurso_9.codigo_clase_recurso as codigo_clase_recurso_9,
        clase_recurso_9.nombre_clase_recurso as nombre_clase_recurso_9
    from clase_recurso
    inner join tipo_clase_recurso tipo_clase_recurso_1 on tipo_clase_recurso_1.numero_tipo_clase_recurso = clase_recurso.numero_tipo_clase_recurso
    inner join tipo_recurso tipo_recurso_2 on tipo_recurso_2.numero_tipo_recurso = clase_recurso.numero_tipo_recurso
    left outer join funcion funcion_3 on funcion_3.id_funcion = clase_recurso.id_funcion_seleccion
    left outer join pagina pagina_4 on pagina_4.id_pagina = clase_recurso.id_pagina_seleccion
    left outer join pagina pagina_5 on pagina_5.id_pagina = clase_recurso.id_pagina_detalle
    left outer join pagina pagina_6 on pagina_6.id_pagina = clase_recurso.id_pagina_funcion
    left outer join clase_recurso clase_recurso_7 on clase_recurso_7.id_clase_recurso = clase_recurso.id_clase_recurso_maestro
    left outer join clase_recurso clase_recurso_8 on clase_recurso_8.id_clase_recurso = clase_recurso.id_clase_recurso_segmento
    left outer join clase_recurso clase_recurso_9 on clase_recurso_9.id_clase_recurso = clase_recurso.id_clase_recurso_base
;
