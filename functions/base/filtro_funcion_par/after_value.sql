create or replace function filtro_funcion_par$av1(x$new filtro_funcion_par%ROWTYPE)
return filtro_funcion_par%ROWTYPE is
    v$new filtro_funcion_par%ROWTYPE;
    v$cop constant enums.operador_com   := operador_com$enum();
    v$tdp constant enums.tipo_dato_par  := tipo_dato_par$enum();
    v$tva constant enums.tipo_valor     := tipo_valor$enum();
    v$rfp funcion_parametro%ROWTYPE;
    v$par parametro%ROWTYPE;
    v$trimmed  filtro_funcion_par.valor%TYPE;
    v$quantity filtro_funcion_par.valor%TYPE;
    v$last_char nvarchar2(1);
    v$unit nvarchar2(1);
begin
    v$new := x$new;
--  select numero_tipo_dato_par, numero_tipo_valor
    select * into v$rfp from funcion_parametro where id_funcion_parametro = v$new.id_funcion_parametro;
    select * into v$par from parametro where id_parametro = v$rfp.id_parametro;
    /*
    if (v$new.version_filtro_funcion_par is null) then
        v$new.version_filtro_funcion_par := 0;
    end if;

    if (v$new.numero_operador_com is null) then
        v$new.numero_operador_com := v$cop.ES_IGUAL;
    end if;
    */
    if (v$new.numero_operador_com < v$cop.ES_IGUAL) then
        v$new.valor := null;
        v$new.valor_fecha_hora := null;
        v$new.id_clase_recurso_valor := null;
        v$new.recurso_valor := null;
        v$new.id_recurso_valor := null;
        v$new.codigo_recurso_valor := null;
        v$new.nombre_recurso_valor := null;
        v$new.pagina_recurso := null;
    elsif (v$rfp.numero_tipo_valor = v$tva.CONTINUO) then
        v$new.id_clase_recurso_valor := null;
        v$new.recurso_valor := null;
        v$new.id_recurso_valor := null;
        v$new.codigo_recurso_valor := null;
        v$new.nombre_recurso_valor := null;
        v$new.pagina_recurso := null;
    elsif (v$rfp.numero_tipo_valor = v$tva.RECURSO) then
--      v$new.valor := null;
        v$new.valor_fecha_hora := null;
        if (v$new.id_clase_recurso_valor is null) then
            v$new.pagina_recurso := null;
        else
            select pagina_detalle into v$new.pagina_recurso from clase_recurso where id_clase_recurso = v$new.id_clase_recurso_valor;
        end if;
    else
        v$new.valor := null;
        v$new.valor_fecha_hora := null;
        v$new.id_clase_recurso_valor := null;
        v$new.recurso_valor := null;
        v$new.id_recurso_valor := null;
        v$new.codigo_recurso_valor := null;
        v$new.nombre_recurso_valor := null;
        v$new.pagina_recurso := null;
    end if;
    /*
    if (v$rfp.numero_tipo_valor = v$tva.CONTINUO and v$par.numero_tipo_dato_par = v$tdp.FECHA_HORA) then
        if (v$new.valor is not null and v$new.valor_fecha_hora is null) then
            v$trimmed := trim(v$new.valor);
            v$last_char := substr(v$trimmed, -1);
            if (v$last_char in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')) then
                v$quantity := v$trimmed;
                v$unit := 'D';
            elsif (v$last_char in ('A', 'Y', 'M', 'D', 'h', 'm', 's')) then
                v$quantity := rtrim(v$trimmed, v$last_char);
                v$unit := v$last_char;
            else
                v$quantity := null;
                v$unit := null;
            end if;
            if (v$quantity is not null and v$unit is not null) then
                v$new.valor := v$quantity||v$unit;
            end if;
        end if;
    end if;
    */
    return v$new;
end;
/
show errors
