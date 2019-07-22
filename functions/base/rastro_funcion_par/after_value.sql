create or replace function rastro_funcion_par$av1(x$new rastro_funcion_par%ROWTYPE)
return rastro_funcion_par%ROWTYPE is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
    v$new rastro_funcion_par%ROWTYPE;
    cursor c$fdc is
        select
            c.id_clase_recurso as id_clase_recurso_valor,
            c.pagina_detalle as pagina_recurso
        from rastro_funcion r
        inner join funcion_parametro p on p.id_funcion = r.id_funcion and p.id_parametro = v$new.id_parametro
        inner join funcion f on f.id_funcion = p.id_funcion_referencia
        inner join dominio d on d.id_dominio = f.id_dominio
        inner join clase_recurso c on c.id_clase_recurso = d.id_clase_recurso;
    v$fdc c$fdc%ROWTYPE;
begin
    v$new := x$new;
    begin
        select
            c.id_clase_recurso as id_clase_recurso_valor,
            c.pagina_detalle as pagina_recurso
        into v$fdc
        from rastro_funcion r
        inner join funcion_parametro p on p.id_funcion = r.id_funcion and p.id_parametro = v$new.id_parametro
        inner join funcion f on f.id_funcion = p.id_funcion_referencia
        inner join dominio d on d.id_dominio = f.id_dominio
        inner join clase_recurso c on c.id_clase_recurso = d.id_clase_recurso
        where r.id_rastro_funcion = v$new.id_rastro_funcion;
        /**/
        v$new.id_clase_recurso_valor := v$fdc.id_clase_recurso_valor;
        v$new.pagina_recurso := v$fdc.pagina_recurso;
    exception
        when no_data_found then
            v$new.id_clase_recurso_valor := null;
            v$new.pagina_recurso := null;
    end;
    if (v$new.valor_parametro is null and v$new.valor_anterior is null) then
        v$new.diferente_valor := v$false;
    elsif (v$new.valor_parametro is null or v$new.valor_anterior is null) then
        v$new.diferente_valor := v$true;
    elsif (v$new.valor_parametro = v$new.valor_anterior) then
        v$new.diferente_valor := v$false;
    else
        v$new.diferente_valor := v$true;
    end if;
    return v$new;
end;
/
show errors
