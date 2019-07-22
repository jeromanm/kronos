create or replace function tarea_usuario$cancelar$batch(x$clase number, x$recurso number, x$funciones nvarchar2) return number is
    v$cmd varchar2(4000);
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    if (x$clase is null) then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('clase de recurso'), 'id', x$clase);
        raise_application_error(v$err, v$msg, true);
    end if;
    if (x$recurso is null) then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('recurso'), 'id', x$recurso);
        raise_application_error(v$err, v$msg, true);
    end if;
    v$cmd := 'update tarea_usuario ';
    v$cmd := v$cmd||'set condicion = 4, fecha_hora_condicion = localtimestamp, finalizador = null ';
    v$cmd := v$cmd||'where id_clase_recurso_valor = '||x$clase||' ';
    v$cmd := v$cmd||'and id_recurso_valor = '||x$recurso||' ';
    if (x$funciones is not null) then
        v$cmd := v$cmd||'and funcion not in ('||x$funciones||') ';
    end if;
    v$cmd := v$cmd||'and condicion in (1,2)';
    execute immediate v$cmd;
    return 0;
end;
/
show errors

create or replace function tarea_usuario$cancelar$biz(x$super number, x$tarea number) return number is
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
    if v$row.condicion not in (1,2) then
        v$msg := util.gettext('la tarea ya esta ejecutada o cancelada');
        raise_application_error(v$err, v$msg, true);
    end if;
    update tarea_usuario
        set condicion = 4, fecha_hora_condicion = localtimestamp, finalizador = v$log.id_usuario
        where tarea = v$row.tarea;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existen %s con %s = %s'), util.gettext('notificaciones de tarea'), util.gettext('tarea'), v$row.tarea);
        raise_application_error(v$err, v$msg, true);
    end if;
    /*
    if (v$row.id_recurso_valor is null) then
        delete from tarea where id_funcion = v$row.funcion and id_recurso_valor is null;
    else
        delete from tarea where id_funcion = v$row.funcion and id_recurso_valor = v$row.id_recurso_valor;
    end if;
    */
    return 0;
end;
/
show errors
