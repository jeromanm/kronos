/*
create or replace function tarea_usuario$update(x$rastro number) return number is
    v$log rastro_proceso%ROWTYPE;
begin
    begin
        select * into v$log from rastro_proceso where id_rastro_proceso = x$rastro;
        if v$log.id_recurso is null then
            update tarea_usuario
                set condicion = 3, fecha_hora_condicion = localtimestamp, finalizador = v$log.id_usuario
                where condicion in (1,2)
                and funcion = v$log.id_funcion
                and id_recurso_valor is null;
        else
            update tarea_usuario
                set condicion = 3, fecha_hora_condicion = localtimestamp, finalizador = v$log.id_usuario
                where condicion in (1,2)
                and funcion = v$log.id_funcion
                and id_recurso_valor = v$log.id_recurso;
        end if;
    exception
        when no_data_found then null;
    end;
    return 0;
end;
/
show errors
*/
create or replace function tarea_usuario$update(x$log rastro_proceso%ROWTYPE) return number is
begin
    if x$log.id_recurso is null then
        update tarea_usuario
            set condicion = 3, fecha_hora_condicion = localtimestamp, finalizador = x$log.id_usuario
            where condicion in (1,2)
            and funcion = x$log.id_funcion
            and id_recurso_valor is null;
    else
        update tarea_usuario
            set condicion = 3, fecha_hora_condicion = localtimestamp, finalizador = x$log.id_usuario
            where condicion in (1,2)
            and funcion = x$log.id_funcion
            and id_recurso_valor = x$log.id_recurso;
    end if;
    return 0;
end;
/
show errors

create or replace function tarea_usuario$private$update(x$funcion number, x$recurso number) return number is
    x$usuario number;
begin
    x$usuario := current_user_id();
    if x$usuario is not null then
        if x$recurso is null then
            update tarea_usuario
                set condicion = 3, fecha_hora_condicion = localtimestamp, finalizador = x$usuario
                where condicion in (1,2)
                and funcion = x$funcion
                and id_recurso_valor is null;
        else
            update tarea_usuario
                set condicion = 3, fecha_hora_condicion = localtimestamp, finalizador = x$usuario
                where condicion in (1,2)
                and funcion = x$funcion
                and id_recurso_valor = x$recurso;
        end if;
    end if;
    return 0;
end;
/
show errors
