create or replace procedure rastro_proceso$aux(x$new rastro_proceso%ROWTYPE, x$old rastro_proceso%ROWTYPE) is
    comando varchar2(2000);
    v$pdq number;
begin
    if (x$new.id_rastro_proceso_superior is null and x$new.id_grupo_proceso is not null) then
        if (x$old.numero_condicion_eje_fun < x$new.numero_condicion_eje_fun) then
            update  grupo_proceso
            set     numero_condicion_eje_fun = x$new.numero_condicion_eje_fun
            where   id_grupo_proceso = x$new.id_grupo_proceso
            and     id_rastro_proceso = x$new.id_rastro_proceso;
        end if;
    elsif (x$new.id_rastro_proceso_superior is not null) then
        if (x$old.numero_condicion_eje_fun = 11 and x$new.numero_condicion_eje_fun = 12) then
            update  rastro_proceso
            set     subprocesos_pendientes  = subprocesos_pendientes  - 1,
                    subprocesos_en_progreso = subprocesos_en_progreso + 1
            where   id_rastro_proceso = x$new.id_rastro_proceso_superior;
        elsif (x$old.numero_condicion_eje_fun = 12 and x$new.numero_condicion_eje_fun = 21) then
            update  rastro_proceso
            set     subprocesos_en_progreso = subprocesos_en_progreso - 1,
                    subprocesos_sin_errores = subprocesos_sin_errores + 1
            where   id_rastro_proceso = x$new.id_rastro_proceso_superior;
        elsif (x$old.numero_condicion_eje_fun = 12 and x$new.numero_condicion_eje_fun = 22) then
            update  rastro_proceso
            set     subprocesos_en_progreso = subprocesos_en_progreso - 1,
                    subprocesos_con_errores = subprocesos_con_errores + 1
            where   id_rastro_proceso = x$new.id_rastro_proceso_superior;
        elsif (x$old.numero_condicion_eje_fun = 11 and x$new.numero_condicion_eje_fun = 23) then
            update  rastro_proceso
            set     subprocesos_pendientes  = subprocesos_pendientes  - 1,
                    subprocesos_cancelados  = subprocesos_cancelados  + 1
            where   id_rastro_proceso = x$new.id_rastro_proceso_superior;
        elsif (x$old.numero_condicion_eje_fun = 12 and x$new.numero_condicion_eje_fun = 23) then
            update  rastro_proceso
            set     subprocesos_en_progreso = subprocesos_en_progreso - 1,
                    subprocesos_cancelados  = subprocesos_cancelados  + 1
            where   id_rastro_proceso = x$new.id_rastro_proceso_superior;
        end if;
    end if;
    if (x$old.numero_condicion_eje_fun < x$new.numero_condicion_eje_fun
    and x$old.procedimiento_after_update is not null
    and x$new.procedimiento_after_update is not null
    and x$new.procedimiento_after_update = x$old.procedimiento_after_update) then
        comando := 'BEGIN '||x$new.procedimiento_after_update||'(:rastro); END;';
        execute immediate comando using x$new.id_rastro_proceso;
    end if;
    if (x$old.numero_condicion_eje_fun < 21 and x$new.numero_condicion_eje_fun = 21) then
--      v$pdq := tarea_usuario$update(x$new.id_rastro_proceso);
        v$pdq := tarea_usuario$update(x$new);
    end if;
end;
/
show errors
