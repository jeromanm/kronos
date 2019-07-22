create or replace function rastro_proceso$insert
(
rastro  number,
usuario number,
codigo_usuario nvarchar2,
nombre_usuario nvarchar2,
x$funcion number,
recurso number,
version_recurso number,
codigo_recurso nvarchar2,
nombre_recurso nvarchar2,
propietario_recurso number,
segmento_recurso number,
etiqueta_lenguaje nvarchar2
)
return number is
    grupo number := NULL;
    row_funcion funcion%ROWTYPE;
    row_rastro_proceso rastro_proceso%ROWTYPE;
begin
    select * into row_funcion from funcion where id_funcion = x$funcion;
    /**/
    grupo                                           := grupo_proceso$lock(rastro, x$funcion);
    row_rastro_proceso.id_rastro_proceso            := rastro;
    row_rastro_proceso.fecha_hora_inicio_ejecucion  := localtimestamp;
    row_rastro_proceso.id_usuario                   := usuario;
    row_rastro_proceso.codigo_usuario               := codigo_usuario;
    row_rastro_proceso.nombre_usuario               := nombre_usuario;
    row_rastro_proceso.id_funcion                   := x$funcion;
    row_rastro_proceso.codigo_funcion               := row_funcion.codigo_funcion;
    row_rastro_proceso.nombre_funcion               := row_funcion.nombre_funcion;
    row_rastro_proceso.id_recurso                   := recurso;
    row_rastro_proceso.version_recurso              := version_recurso;
    row_rastro_proceso.codigo_recurso               := substr(codigo_recurso, 1, 100);
    row_rastro_proceso.nombre_recurso               := substr(nombre_recurso, 1, 100);
    row_rastro_proceso.id_propietario_recurso       := propietario_recurso;
    row_rastro_proceso.id_segmento_recurso          := segmento_recurso;
    row_rastro_proceso.etiqueta_lenguaje            := etiqueta_lenguaje;
    row_rastro_proceso.numero_condicion_eje_fun     := 11;
    row_rastro_proceso.id_grupo_proceso             := grupo;
    row_rastro_proceso.subprocesos                  := 0;
    row_rastro_proceso.subprocesos_pendientes       := 0;
    row_rastro_proceso.subprocesos_en_progreso      := 0;
    row_rastro_proceso.subprocesos_sin_errores      := 0;
    row_rastro_proceso.subprocesos_con_errores      := 0;
    row_rastro_proceso.subprocesos_cancelados       := 0;
    /**/
    insert into rastro_proceso values row_rastro_proceso;
    /**/
    return row_rastro_proceso.id_rastro_proceso;
end;
/
show errors

create or replace function rastro_proceso$insert$010
(
rastro number,
usuario number,
codigo_usuario nvarchar2,
nombre_usuario nvarchar2,
x$funcion number
)
return number is
    grupo number := NULL;
    row_funcion funcion%ROWTYPE;
    row_rastro_proceso rastro_proceso%ROWTYPE;
begin
    select * into row_funcion from funcion where id_funcion = x$funcion;
    /**/
    grupo                                           := grupo_proceso$lock(rastro, x$funcion);
    row_rastro_proceso.id_rastro_proceso            := rastro;
    row_rastro_proceso.fecha_hora_inicio_ejecucion  := localtimestamp;
    row_rastro_proceso.id_usuario                   := usuario;
    row_rastro_proceso.codigo_usuario               := codigo_usuario;
    row_rastro_proceso.nombre_usuario               := nombre_usuario;
    row_rastro_proceso.id_funcion                   := x$funcion;
    row_rastro_proceso.codigo_funcion               := row_funcion.codigo_funcion;
    row_rastro_proceso.nombre_funcion               := row_funcion.nombre_funcion;
    row_rastro_proceso.numero_condicion_eje_fun     := 11;
    row_rastro_proceso.id_grupo_proceso             := grupo;
    row_rastro_proceso.subprocesos                  := 0;
    row_rastro_proceso.subprocesos_pendientes       := 0;
    row_rastro_proceso.subprocesos_en_progreso      := 0;
    row_rastro_proceso.subprocesos_sin_errores      := 0;
    row_rastro_proceso.subprocesos_con_errores      := 0;
    row_rastro_proceso.subprocesos_cancelados       := 0;
    /**/
    insert into rastro_proceso values row_rastro_proceso;
    /**/
    return row_rastro_proceso.id_rastro_proceso;
end;
/
show errors
