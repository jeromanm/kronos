exec xsp.dropone('function', 'usuario$agregar$biz');
create or replace function usuario$agregar$biz(x$super number, x$codigo varchar2, x$nombre varchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg varchar2(4000); -- a character string of at most 2048 bytes?
begin
--
--  Usuario.agregar - business logic
--
    insert
    into usuario
        (
        id_usuario,
        codigo_usuario,
        nombre_usuario,
        es_usuario_automatico,
        fecha_hora_registro
        )
    values
        (
        util.bigintid(),
        x$codigo,
        x$nombre,
        'true',
        localtimestamp
        );
    /**/
    return 0;
end;
/
show errors
