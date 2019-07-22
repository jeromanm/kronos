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
exec xsp.dropone('view', 'consulta_tarea_usuario');
create view consulta_tarea_usuario as
select
    tarea_usuario.id,
    tarea_usuario.version,
    tarea_usuario.tarea,
    tarea_usuario.destinatario,
    tarea_usuario.funcion,
    tarea_usuario.pagina_funcion,
    tarea_usuario.id_clase_recurso_valor,
    tarea_usuario.recurso_valor,
    tarea_usuario.id_recurso_valor,
    tarea_usuario.codigo_recurso_valor,
    tarea_usuario.nombre_recurso_valor,
    tarea_usuario.pagina_recurso,
    tarea_usuario.responsable,
    tarea_usuario.supervisor,
    tarea_usuario.finalizador,
    tarea_usuario.supervisor_superior,
    tarea_usuario.condicion,
    tarea_usuario.fecha_hora_condicion,
    tarea_usuario.fecha_hora_asignacion,
    tarea_usuario.fecha_hora_abandono,
    tarea_usuario.fecha_hora_registro,
    tarea_usuario.fecha_hora_limite,
    tarea_usuario.prioridad,
    tarea_usuario.fecha_hora_ultimo_correo,
    tarea_usuario.notificar_destinatario,
    tarea_usuario.proxima_nota_destinatario,
    tarea_usuario.ultima_nota_destinatario,
    tarea_usuario.notificar_supervisor,
    tarea_usuario.proxima_nota_supervisor,
    tarea_usuario.ultima_nota_supervisor,
    tarea_usuario.advertir_asignar,
    tarea_usuario.proximo_advertir_asignar,
    tarea_usuario.ultimo_advertir_asignar,
    tarea_usuario.advertir_finalizar,
    tarea_usuario.proximo_advertir_finalizar,
    tarea_usuario.ultimo_advertir_finalizar,
    tarea_usuario.escalar_asignar,
    tarea_usuario.proximo_escalar_asignar,
    tarea_usuario.ultimo_escalar_asignar,
    tarea_usuario.escalar_finalizar,
    tarea_usuario.proximo_escalar_finalizar,
    tarea_usuario.ultimo_escalar_finalizar,
        usuario_1.codigo_usuario as codigo_usuario_1,
        usuario_1.nombre_usuario as nombre_usuario_1,
        funcion_2.codigo_funcion as codigo_funcion_2,
        funcion_2.nombre_funcion as nombre_funcion_2,
        usuario_4.codigo_usuario as codigo_usuario_4,
        usuario_4.nombre_usuario as nombre_usuario_4,
        usuario_5.codigo_usuario as codigo_usuario_5,
        usuario_5.nombre_usuario as nombre_usuario_5,
        usuario_6.codigo_usuario as codigo_usuario_6,
        usuario_6.nombre_usuario as nombre_usuario_6,
        usuario_7.codigo_usuario as codigo_usuario_7,
        usuario_7.nombre_usuario as nombre_usuario_7,
        condicion_tarea_8.numero_condicion_tarea as numero_condicion_tarea_8,
        condicion_tarea_8.codigo_condicion_tarea as codigo_condicion_tarea_8
    from tarea_usuario
    inner join usuario usuario_1 on usuario_1.id_usuario = tarea_usuario.destinatario
    left outer join funcion funcion_2 on funcion_2.id_funcion = tarea_usuario.funcion
    left outer join usuario usuario_4 on usuario_4.id_usuario = tarea_usuario.responsable
    left outer join usuario usuario_5 on usuario_5.id_usuario = tarea_usuario.supervisor
    left outer join usuario usuario_6 on usuario_6.id_usuario = tarea_usuario.finalizador
    left outer join usuario usuario_7 on usuario_7.id_usuario = tarea_usuario.supervisor_superior
    inner join condicion_tarea condicion_tarea_8 on condicion_tarea_8.numero_condicion_tarea = tarea_usuario.condicion
    where ((tarea_usuario.condicion = 2) or ((tarea_usuario.condicion = 1) and (tarea_usuario.destinatario = tarea_usuario.responsable)))
;
