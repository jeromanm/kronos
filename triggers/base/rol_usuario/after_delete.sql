create or replace procedure rol_usuario$adx(x$old rol_usuario%ROWTYPE) is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
begin
    update usuario set es_usuario_modificado = v$true where id_usuario = x$old.id_usuario;
end;
/
show errors
