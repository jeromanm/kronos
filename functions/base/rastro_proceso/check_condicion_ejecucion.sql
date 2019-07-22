create or replace function rastro_proceso$check(rastro number, condicion number) return number is
    condicion_proceso number(10);
    row_rastro_proceso rastro_proceso%ROWTYPE;
    row_grupo_proceso grupo_proceso%ROWTYPE;
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    begin
        select  *
        into    row_rastro_proceso
        from    rastro_proceso
        where   id_rastro_proceso = rastro;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('proceso'), 'id', rastro);
            raise_application_error(v$err, v$msg, true);
    end;
    if (row_rastro_proceso.numero_condicion_eje_fun <> condicion) then
        v$msg := util.format(util.gettext('proceso %s no se encuentra en condicion %s sino en condicion %s'), rastro, condicion, row_rastro_proceso.numero_condicion_eje_fun);
        raise_application_error(v$err, v$msg, true);
    elsif (row_rastro_proceso.id_rastro_proceso_superior is not null) then
        condicion_proceso := rastro_proceso$check(row_rastro_proceso.id_rastro_proceso_superior, 12);
    elsif (row_rastro_proceso.id_grupo_proceso is not null) then
        begin
            select  *
            into    row_grupo_proceso
            from    grupo_proceso
            where   id_grupo_proceso = row_rastro_proceso.id_grupo_proceso;
        exception
            when no_data_found then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('grupo'), 'id', row_rastro_proceso.id_grupo_proceso);
                raise_application_error(v$err, v$msg, true);
        end;
        if (row_grupo_proceso.id_rastro_proceso is null or row_grupo_proceso.id_rastro_proceso <> row_rastro_proceso.id_rastro_proceso) then
            v$msg := util.format(util.gettext('grupo %s no esta ejecutando el proceso %s'), row_rastro_proceso.id_grupo_proceso, row_rastro_proceso.id_rastro_proceso);
            raise_application_error(v$err, v$msg, true);
        elsif (row_grupo_proceso.numero_condicion_eje_fun is null or row_grupo_proceso.numero_condicion_eje_fun > 12) then
            v$msg := util.format(util.gettext('grupo %s no esta ejecutando el proceso %s'), row_rastro_proceso.id_grupo_proceso, row_rastro_proceso.id_rastro_proceso);
            raise_application_error(v$err, v$msg, true);
        else
            condicion_proceso := row_grupo_proceso.numero_condicion_eje_fun;
        end if;
    else
        condicion_proceso := condicion;
    end if;
    return condicion_proceso;
end;
/
show errors
