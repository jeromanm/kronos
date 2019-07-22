create or replace procedure rol_funcion$aux(x$new rol_funcion%ROWTYPE, x$old rol_funcion%ROWTYPE) is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
begin
    update usuario set es_usuario_modificado = v$true where id_usuario in (
    select id_usuario from rol_usuario where id_rol = x$new.id_rol);
end;
/
show errors
