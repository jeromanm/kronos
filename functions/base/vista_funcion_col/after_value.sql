create or replace function vista_funcion_col$av1(x$new vista_funcion_col%ROWTYPE)
return vista_funcion_col%ROWTYPE is
    v$new vista_funcion_col%ROWTYPE;
    v$tag constant enums.tipo_agregacion := tipo_agregacion$enum();
    v$tdp constant enums.tipo_dato_par   := tipo_dato_par$enum();
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
    v$funcion_parametro funcion_parametro%ROWTYPE;
    v$parametro parametro%ROWTYPE;
    v$splitted_alias nvarchar2(2000);
    v$max_secuencia number(10);
begin
    v$new := x$new;
    -- raise notice 'vista_funcion_col$after_value(new=%)', v$new;
    if (v$new.agregacion is not null) then
        select * into v$funcion_parametro from funcion_parametro where id_funcion_parametro = v$new.columna;
        select * into v$parametro from parametro where id_parametro = v$funcion_parametro.id_parametro;
    end if;
    v$splitted_alias := util.split_part(v$new.alias, '.', 3);
    if (v$splitted_alias is not null) then
        v$new.alias := v$splitted_alias;
    end if;
    select secuencia into v$max_secuencia from vista_funcion where id = v$new.vista;
    if (v$new.secuencia is null or v$new.secuencia = 0) then
        v$new.secuencia := 10 + 10*ceil(v$max_secuencia/10);
    end if;
    if (v$new.secuencia > v$max_secuencia) then
        update vista_funcion set secuencia = v$new.secuencia where id = v$new.vista;
    end if;
    if (v$new.agregacion is null) then
        v$new.graficable := v$false;
    elsif (v$new.agregacion = v$tag.GRUPO) then
        v$new.orden := v$true;
        v$new.graficable := v$false;
    elsif (v$parametro.numero_tipo_dato_par = v$tdp.ALFANUMERICO) then
        v$new.agregacion := v$tag.CUENTA;
        v$new.graficable := v$true;
    elsif (v$parametro.numero_tipo_dato_par = v$tdp.NUMERICO) then
        v$new.graficable := v$true;
    elsif (v$parametro.numero_tipo_dato_par = v$tdp.FECHA_HORA) then
        if (v$new.agregacion = v$tag.CUENTA) then
            v$new.graficable := v$true;
        elsif (v$new.agregacion in (v$tag.MINIMO, v$tag.MAXIMO, v$tag.CUENTA_MINIMO_MAXIMO, v$tag.MINIMO_MAXIMO)) then
            v$new.graficable := v$false;
        else
            v$new.agregacion := v$tag.CUENTA;
            v$new.graficable := v$true;
        end if;
    elsif (v$parametro.numero_tipo_dato_par = v$tdp.ENTERO) then
        v$new.graficable := v$true;
    elsif (v$parametro.numero_tipo_dato_par = v$tdp.ENTERO_GRANDE) then
        v$new.agregacion := v$tag.CUENTA;
        v$new.graficable := v$true;
    elsif (v$parametro.numero_tipo_dato_par = v$tdp.LOGICO) then
        v$new.agregacion := v$tag.CUENTA;
        v$new.graficable := v$true;
    else
        v$new.agregacion := null;
        v$new.graficable := v$false;
    end if;
    if (v$new.agregacion is not null) then
        v$new.grupo := null;
    end if;
    if (v$new.grupo is not null) then
        v$new.orden := v$false;
    end if;
    return v$new;
end;
/
show errors

create or replace function vista_funcion_col$av2(x$new vista_funcion_col%ROWTYPE, x$old vista_funcion_col%ROWTYPE)
return vista_funcion_col%ROWTYPE is
    v$new vista_funcion_col%ROWTYPE;
    v$tag constant enums.tipo_agregacion := tipo_agregacion$enum();
begin
    v$new := x$new;
    -- raise notice 'vista_funcion_col$after_value(new=%, old=%)', v$new, x$old;
    if (x$old.agregacion is null) then
        if (v$new.agregacion is not null) then
            v$new.grupo := null;
        end if;
    elsif (x$old.grupo is null) then
        if (v$new.grupo is not null) then
            v$new.agregacion := null;
        end if;
    end if;
    return vista_funcion_col$av1(v$new);
end;
/
show errors
