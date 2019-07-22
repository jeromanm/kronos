create or replace function rastro_proceso$av1(x$new rastro_proceso%ROWTYPE)
return rastro_proceso%ROWTYPE is
    v$new rastro_proceso%ROWTYPE;
    cursor c$fdc is
        select
            f.numero_tipo_funcion as tipo_funcion,
            d.id_clase_recurso as id_clase_recurso_valor,
            c.pagina_funcion as pagina_funcion,
            c.pagina_detalle as pagina_recurso
        from funcion f
        inner join dominio d on d.id_dominio = f.id_dominio
        inner join clase_recurso c on c.id_clase_recurso = d.id_clase_recurso;
    v$fdc c$fdc%ROWTYPE;
    v$etf constant enums.tipo_funcion := tipo_funcion$enum();
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    v$new := x$new;
    if (v$new.id_recurso is not null) then
        if (v$new.codigo_recurso is null) then
            v$new.codigo_recurso := util.gettext('string.valor.recurso.sin.codigo');
        end if;
        if (v$new.nombre_recurso is null) then
            v$new.nombre_recurso := util.gettext('string.valor.recurso.sin.nombre');
        end if;
    end if;
    begin
        select
            f.numero_tipo_funcion as tipo_funcion,
            d.id_clase_recurso as id_clase_recurso_valor,
            c.pagina_funcion as pagina_funcion,
            c.pagina_detalle as pagina_recurso
        into v$fdc
        from funcion f
        inner join dominio d on d.id_dominio = f.id_dominio
        inner join clase_recurso c on c.id_clase_recurso = d.id_clase_recurso
        where f.id_funcion = v$new.id_funcion;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('funcion'), 'id', v$new.id_funcion);
            raise_application_error(v$err, v$msg, true);
    end;
    v$new.recurso_valor := v$new.id_recurso;
    v$new.id_clase_recurso_valor := v$fdc.id_clase_recurso_valor;
    if (v$fdc.tipo_funcion in (v$etf.CONSULTA, v$etf.CREACION, v$etf.MODIFICACION, v$etf.ELIMINACION)) then
        v$new.pagina_funcion := v$fdc.pagina_recurso;
    else
        v$new.pagina_funcion := v$fdc.pagina_funcion;
    end if;
    v$new.pagina_recurso := v$fdc.pagina_recurso;
    return v$new;
end;
/
show errors

create or replace function rastro_proceso$av2(x$new rastro_proceso%ROWTYPE, x$old rastro_proceso%ROWTYPE)
return rastro_proceso%ROWTYPE is
    v$new rastro_proceso%ROWTYPE;
    suma_vieja number(10);
    suma_nueva number(10);
begin
    v$new := x$new;
    if (x$old.subprocesos = v$new.subprocesos and v$new.subprocesos > 0
    and x$old.numero_condicion_eje_fun = v$new.numero_condicion_eje_fun and v$new.numero_condicion_eje_fun = 12) then
        suma_vieja := x$old.subprocesos_sin_errores + x$old.subprocesos_con_errores + x$old.subprocesos_cancelados;
        suma_nueva := v$new.subprocesos_sin_errores + v$new.subprocesos_con_errores + v$new.subprocesos_cancelados;
        if (suma_vieja < suma_nueva and suma_nueva = v$new.subprocesos) then
            v$new.fecha_hora_fin_ejecucion := localtimestamp;
            v$new.descripcion_error := 'ejecucion del proceso ' || v$new.id_rastro_proceso || ' finalizada';
            if (v$new.subprocesos_cancelados > 0) then
                v$new.numero_condicion_eje_fun := 23;
            elsif (v$new.subprocesos_con_errores > 0) then
                v$new.numero_condicion_eje_fun := 22;
            else
                v$new.numero_condicion_eje_fun := 21;
            end if;
        end if;
    end if;
    return v$new;
end;
/
show errors
