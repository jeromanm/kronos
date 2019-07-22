create or replace function grupo_proceso$lock(rastro number, f number) return number is
    grupo number(19);
    codigo nvarchar2(2000);
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    begin
        select  id_grupo_proceso
        into    grupo
        from    funcion
        where   id_funcion = f;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('funcion'), 'id', f);
            raise_application_error(v$err, v$msg, true);
    end;
    /**/
    if (grupo is not null) then
        begin
            select  codigo_grupo_proceso
            into    codigo
            from    grupo_proceso
            where   id_grupo_proceso = grupo;
        exception
            when no_data_found then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('grupo'), 'id', grupo);
                raise_application_error(v$err, v$msg, true);
        end;
        /**/
        update	grupo_proceso
        set     id_rastro_proceso = rastro, numero_condicion_eje_fun = 11
        where	id_grupo_proceso = grupo and (numero_condicion_eje_fun is null or numero_condicion_eje_fun > 12);
        /**/
        if not SQL%FOUND then
            v$msg := util.format(util.gettext('no se puede ejecutar este proceso en este momento porque se esta ejecutando otro proceso del grupo %s'), codigo);
            raise_application_error(v$err, v$msg, true);
        end if;
        /**/
    end if;
    return grupo;
end;
/
show errors
