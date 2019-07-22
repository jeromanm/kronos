create or replace function rastro_funcion_par$insert
(
serial number,
rastro number,
x$parametro number,
valor_parametro nvarchar2,
valor_anterior nvarchar2,
codigo_recurso_parametro nvarchar2,
nombre_recurso_parametro nvarchar2,
valor_aparente_parametro nvarchar2,
codigo_recurso_anterior nvarchar2,
nombre_recurso_anterior nvarchar2,
valor_aparente_anterior nvarchar2
)
return number is
    row_parametro parametro%ROWTYPE;
    row_rastro_funcion_par rastro_funcion_par%ROWTYPE;
begin
    select * into row_parametro from parametro where id_parametro = x$parametro;
    /**/
    row_rastro_funcion_par.id_rastro_funcion_par := serial;
    row_rastro_funcion_par.id_rastro_funcion     := rastro;
    row_rastro_funcion_par.id_parametro          := x$parametro;
    row_rastro_funcion_par.codigo_parametro      := row_parametro.codigo_parametro;
    row_rastro_funcion_par.nombre_parametro      := row_parametro.nombre_parametro;
    row_rastro_funcion_par.valor_parametro       := valor_parametro;
    row_rastro_funcion_par.valor_anterior        := valor_anterior;
    /**/
    row_rastro_funcion_par.codigo_recurso_parametro := codigo_recurso_parametro;
    row_rastro_funcion_par.nombre_recurso_parametro := nombre_recurso_parametro;
    row_rastro_funcion_par.valor_aparente_parametro := valor_aparente_parametro;
    /**/
    row_rastro_funcion_par.codigo_recurso_anterior  := codigo_recurso_anterior;
    row_rastro_funcion_par.nombre_recurso_anterior  := nombre_recurso_anterior;
    row_rastro_funcion_par.valor_aparente_anterior  := valor_aparente_anterior;
    /**/
    insert into rastro_funcion_par values row_rastro_funcion_par;
    /**/
    return row_rastro_funcion_par.id_rastro_funcion_par;
end;
/
show errors

create or replace function rastro_funcion_par$insert$010(rastro number, parametro number, valor_parametro nvarchar2)
return number is
    v$big number(19);
begin
    if (rastro is not null and rastro > 0) then
        v$big := util.bigintid();
        return rastro_funcion_par$insert(v$big, rastro, parametro, valor_parametro, null, null, null, null, null, null, null);
    end if;
    return null;
end;
/
show errors

create or replace function rastro_funcion_par$insert$020(rastro number, parametro number, valor_parametro nvarchar2, valor_anterior nvarchar2)
return number is
    v$big number(19);
begin
    if (rastro is not null and rastro > 0) then
        v$big := util.bigintid();
        return rastro_funcion_par$insert(v$big, rastro, parametro, valor_parametro, valor_anterior, null, null, null, null, null, null);
    end if;
    return null;
end;
/
show errors
