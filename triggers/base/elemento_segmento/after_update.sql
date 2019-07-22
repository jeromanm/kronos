create or replace procedure elemento_segmento$aux(x$new elemento_segmento%ROWTYPE, x$old elemento_segmento%ROWTYPE) is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
begin
    update usuario set es_usuario_modificado = v$true where id_usuario in (
    select id_usuario from rol_usuario where id_rol in (
    select id_rol from rol_funcion where id_conjunto_segmento = x$new.id_conjunto_segmento));
end;
/
show errors
