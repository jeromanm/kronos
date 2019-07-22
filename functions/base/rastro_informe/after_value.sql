create or replace function rastro_informe$av1(x$new rastro_informe%ROWTYPE)
return rastro_informe%ROWTYPE is
    v$new rastro_informe%ROWTYPE;
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
/*
create or replace function rastro_informe$av2(x$new rastro_informe%ROWTYPE, x$old rastro_informe%ROWTYPE)
return rastro_informe%ROWTYPE is
begin
    return x$new;
end;
/
show errors
*/
