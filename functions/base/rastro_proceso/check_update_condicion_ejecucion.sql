create or replace function rastro_proceso$check_update(rastro number) return number is
    condicion_proceso number(10);
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    condicion_proceso := rastro_proceso$check(rastro, 11);
    v$msg := util.format(util.gettext('ejecucion del proceso %s en progreso'), rastro);
    /**/
    update  rastro_proceso
    set     numero_condicion_eje_fun = 12,
            descripcion_error = v$msg
    where   id_rastro_proceso = rastro
    and     numero_condicion_eje_fun = 11;
    /**/
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s, o no se puede colocar en condicion %s'), util.gettext('proceso'), 'id', rastro, 12);
        raise_application_error(v$err, v$msg, true);
    end if;
    /**/
    return condicion_proceso;
end;
/
show errors
