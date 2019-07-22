create or replace function archivo_adjunto$insert
(
x$id number,
x$archivo_cliente nvarchar2,
x$archivo_servidor nvarchar2,
x$id_propietario number,
x$codigo_propietario nvarchar2,
x$nombre_propietario nvarchar2,
x$tipo_contenido nvarchar2,
x$longitud number,
x$octetos blob
)
return number is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
    v$restaurable varchar2(5);
begin
    if (x$octetos is null) then
        v$restaurable := v$false;
    else
        v$restaurable := v$true;
    end if;
    insert
    into archivo_adjunto
        (
        id,
        archivo_cliente,
        archivo_servidor,
        propietario,
        codigo_usuario_propietario,
        nombre_usuario_propietario,
        tipo_contenido,
        longitud,
        octetos,
        restaurable
        )
    values
        (
        x$id,
        x$archivo_cliente,
        x$archivo_servidor,
        x$id_propietario,
        x$codigo_propietario,
        x$nombre_propietario,
        x$tipo_contenido,
        x$longitud,
        x$octetos,
        v$restaurable
        );
    /**/
    return 0;
end;
/
show errors

create or replace function archivo_adjunto$insert$010
(
x$id number,
x$archivo_cliente nvarchar2,
x$archivo_servidor nvarchar2,
x$codigo_usuario nvarchar2,
x$tipo_contenido nvarchar2,
x$longitud number,
x$octetos blob
)
return number is
    v$usuario usuario%ROWTYPE;
begin
    select * into v$usuario from usuario where codigo_usuario = x$codigo_usuario;
    return archivo_adjunto$insert
        (
        x$id,
        x$archivo_cliente,
        x$archivo_servidor,
        v$usuario.id_usuario,
        v$usuario.codigo_usuario,
        v$usuario.nombre_usuario,
        x$tipo_contenido,
        x$longitud,
        x$octetos
        );
end;
/
show errors
