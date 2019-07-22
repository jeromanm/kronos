create or replace function rastro_funcion$insert
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
numero_condicion_eje_fun number,
descripcion_error nvarchar2
)
return number is
    row_funcion funcion%ROWTYPE;
    row_rastro_funcion rastro_funcion%ROWTYPE;
begin
    select * into row_funcion from funcion where id_funcion = x$funcion;
    /**/
    row_rastro_funcion.id_rastro_funcion        := rastro;
    row_rastro_funcion.fecha_hora_ejecucion     := localtimestamp;
    row_rastro_funcion.id_usuario               := usuario;
    row_rastro_funcion.codigo_usuario           := codigo_usuario;
    row_rastro_funcion.nombre_usuario           := nombre_usuario;
    row_rastro_funcion.id_funcion               := x$funcion;
    row_rastro_funcion.codigo_funcion           := row_funcion.codigo_funcion;
    row_rastro_funcion.nombre_funcion           := row_funcion.nombre_funcion;
    row_rastro_funcion.id_recurso               := recurso;
    row_rastro_funcion.version_recurso          := version_recurso;
    row_rastro_funcion.codigo_recurso           := substr(codigo_recurso, 1, 100);
    row_rastro_funcion.nombre_recurso           := substr(nombre_recurso, 1, 100);
    row_rastro_funcion.id_propietario_recurso   := propietario_recurso;
    row_rastro_funcion.id_segmento_recurso      := segmento_recurso;
    row_rastro_funcion.numero_condicion_eje_fun := numero_condicion_eje_fun;
    row_rastro_funcion.descripcion_error        := substr(descripcion_error, 1, 2000);
    /**/
    insert into rastro_funcion values row_rastro_funcion;
    /**/
    return row_rastro_funcion.id_rastro_funcion;
end;
/
show errors

create or replace function rastro_funcion$insert$010(rastro number)
return number is
    v$big number(19);
begin
    if (rastro is not null and rastro > 0) then
        v$big := util.bigintid();
        insert
        into rastro_funcion
            (
            id_rastro_funcion,
            fecha_hora_ejecucion,
            id_usuario,
            codigo_usuario,
            nombre_usuario,
            id_funcion,
            codigo_funcion,
            nombre_funcion,
            id_recurso,
            version_recurso,
            codigo_recurso,
            nombre_recurso,
            id_propietario_recurso,
            id_segmento_recurso,
            numero_condicion_eje_fun,
            descripcion_error
            )
        select
            v$big,
            fecha_hora_inicio_ejecucion,
            id_usuario,
            codigo_usuario,
            nombre_usuario,
            id_funcion,
            codigo_funcion,
            nombre_funcion,
            id_recurso,
            version_recurso,
            codigo_recurso,
            nombre_recurso,
            id_propietario_recurso,
            id_segmento_recurso,
            numero_condicion_eje_fun,
            descripcion_error
        from rastro_proceso
        where id_rastro_proceso = rastro;
    end if;
    return v$big;
end;
/
show errors
