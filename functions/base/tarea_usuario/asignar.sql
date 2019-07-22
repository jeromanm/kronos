create or replace function tarea_usuario$asignar$biz(x$super number, x$tarea number) return number is
    v$log rastro_proceso%ROWTYPE;
    v$row tarea_usuario%ROWTYPE;
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    begin
        select * into v$log from rastro_proceso where id_rastro_proceso = x$super;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('rastro de proceso'), 'id', x$super);
            raise_application_error(v$err, v$msg, true);
    end;
    /**/
    begin
        select * into v$row from tarea_usuario where id = x$tarea;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('notificacion de tarea'), 'id', x$tarea);
            raise_application_error(v$err, v$msg, true);
    end;
    /**/
    if v$row.condicion <> 2 then
        v$msg := util.gettext('la tarea no esta disponible');
        raise_application_error(v$err, v$msg, true);
    end if;
    /**/
    update tarea_usuario
        set condicion = 1, fecha_hora_condicion = localtimestamp, responsable = v$row.destinatario, supervisor_superior = null
        where tarea = v$row.tarea;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existen %s con %s = %s'), util.gettext('notificaciones de tarea'), util.gettext('tarea'), v$row.tarea);
        raise_application_error(v$err, v$msg, true);
    end if;
    if v$row.destinatario = v$log.id_usuario then
        update tarea_usuario
            set fecha_hora_asignacion = localtimestamp, supervisor = null
            where id = x$tarea;
    else
        update tarea_usuario
            set fecha_hora_asignacion = localtimestamp, supervisor = v$log.id_usuario
            where id = x$tarea;
    end if;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('notificacion de tarea'), 'id', x$tarea);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
show errors
