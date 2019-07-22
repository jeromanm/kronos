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
exec xsp.dropone('view', 'consulta_usuario');
create view consulta_usuario as
select
    usuario.id_usuario,
    usuario.version_usuario,
    usuario.codigo_usuario,
    usuario.nombre_usuario,
    usuario.password_usuario,
    usuario.correo_electronico,
    usuario.es_super_usuario,
    usuario.es_usuario_especial,
    usuario.es_usuario_inactivo,
    usuario.es_usuario_modificado,
    usuario.es_usuario_automatico,
    usuario.fecha_hora_registro,
    usuario.id_usuario_supervisor,
    usuario.octetos,
    usuario.limite_archivo_detalle,
    usuario.limite_archivo_resumen,
    usuario.limite_informe_detalle,
    usuario.limite_informe_resumen,
    usuario.limite_informe_grafico,
    usuario.menus_restringidos,
    usuario.operadores_restringidos,
    usuario.filtros_restringidos,
    usuario.vistas_restringidas,
    usuario.pagina_inicio,
    usuario.pagina_menu,
    usuario.otra_pagina,
    usuario.tema_interfaz,
    usuario.filas_por_pagina,
    usuario.ayuda_por_campos,
        usuario_1.codigo_usuario as codigo_usuario_1,
        usuario_1.nombre_usuario as nombre_usuario_1,
        pagina_inicio_2.numero as numero_2,
        pagina_inicio_2.codigo as codigo_2,
        pagina_3.codigo_pagina as codigo_pagina_3,
        pagina_3.nombre_pagina as nombre_pagina_3,
        pagina_especial_4.codigo as codigo_4,
        pagina_especial_4.descripcion as descripcion_4
    from usuario
    left outer join usuario usuario_1 on usuario_1.id_usuario = usuario.id_usuario_supervisor
    left outer join pagina_inicio pagina_inicio_2 on pagina_inicio_2.numero = usuario.pagina_inicio
    left outer join pagina pagina_3 on pagina_3.id_pagina = usuario.pagina_menu
    left outer join pagina_especial pagina_especial_4 on pagina_especial_4.id = usuario.otra_pagina
;
