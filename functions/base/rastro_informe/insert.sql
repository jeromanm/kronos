create or replace function rastro_informe$insert
(
rastro number,
usuario number,
codigo_usuario nvarchar2,
nombre_usuario nvarchar2,
x$funcion number,
informe nvarchar2,
formato nvarchar2,
limite number,
etiqueta_lenguaje nvarchar2,
instruccion nvarchar2,
restringido varchar2
)
return number is
    row_funcion funcion%ROWTYPE;
    row_rastro_informe rastro_informe%ROWTYPE;
begin
    select * into row_funcion from funcion where id_funcion = x$funcion;
    /**/
    row_rastro_informe.id_rastro_informe            := rastro;
    row_rastro_informe.fecha_hora_inicio_ejecucion  := localtimestamp;
    row_rastro_informe.id_usuario                   := usuario;
    row_rastro_informe.codigo_usuario               := codigo_usuario;
    row_rastro_informe.nombre_usuario               := nombre_usuario;
    row_rastro_informe.id_funcion                   := x$funcion;
    row_rastro_informe.codigo_funcion               := row_funcion.codigo_funcion;
    row_rastro_informe.nombre_funcion               := row_funcion.nombre_funcion;
    row_rastro_informe.nombre_informe               := informe;
    row_rastro_informe.formato_informe              := formato;
    row_rastro_informe.limite_filas                 := limite;
    row_rastro_informe.etiqueta_lenguaje            := etiqueta_lenguaje;
    row_rastro_informe.instruccion_select           := instruccion;
    row_rastro_informe.select_restringido           := restringido;
    row_rastro_informe.numero_condicion_eje_fun     := 11;
    /**/
    insert into rastro_informe values row_rastro_informe;
    /**/
    return row_rastro_informe.id_rastro_informe;
end;
/
show errors

create or replace function rastro_informe$insert$010
(
rastro number,
usuario number,
codigo_usuario nvarchar2,
nombre_usuario nvarchar2,
x$funcion number
)
return number is
    row_funcion funcion%ROWTYPE;
    row_rastro_informe rastro_informe%ROWTYPE;
begin
    select * into row_funcion from funcion where id_funcion = x$funcion;
    /**/
    row_rastro_informe.id_rastro_informe            := rastro;
    row_rastro_informe.fecha_hora_inicio_ejecucion  := localtimestamp;
    row_rastro_informe.id_usuario                   := usuario;
    row_rastro_informe.codigo_usuario               := codigo_usuario;
    row_rastro_informe.nombre_usuario               := nombre_usuario;
    row_rastro_informe.id_funcion                   := x$funcion;
    row_rastro_informe.codigo_funcion               := row_funcion.codigo_funcion;
    row_rastro_informe.nombre_funcion               := row_funcion.nombre_funcion;
    row_rastro_informe.numero_condicion_eje_fun     := 11;
    /**/
    insert into rastro_informe values row_rastro_informe;
    /**/
    return row_rastro_informe.id_rastro_informe;
end;
/
show errors

create or replace function rastro_informe$insert$020
(
rastro number,
usuario number,
codigo_usuario nvarchar2,
nombre_usuario nvarchar2,
x$funcion number,
informe nvarchar2,
formato nvarchar2,
limite number
)
return number is
    row_funcion funcion%ROWTYPE;
    row_rastro_informe rastro_informe%ROWTYPE;
begin
    select * into row_funcion from funcion where id_funcion = x$funcion;
    /**/
    row_rastro_informe.id_rastro_informe            := rastro;
    row_rastro_informe.fecha_hora_inicio_ejecucion  := localtimestamp;
    row_rastro_informe.id_usuario                   := usuario;
    row_rastro_informe.codigo_usuario               := codigo_usuario;
    row_rastro_informe.nombre_usuario               := nombre_usuario;
    row_rastro_informe.id_funcion                   := x$funcion;
    row_rastro_informe.codigo_funcion               := row_funcion.codigo_funcion;
    row_rastro_informe.nombre_funcion               := row_funcion.nombre_funcion;
    row_rastro_informe.nombre_informe               := informe;
    row_rastro_informe.formato_informe              := formato;
    row_rastro_informe.limite_filas                 := limite;
    row_rastro_informe.numero_condicion_eje_fun     := 11;
    /**/
    insert into rastro_informe values row_rastro_informe;
    /**/
    return row_rastro_informe.id_rastro_informe;
end;
/
show errors
