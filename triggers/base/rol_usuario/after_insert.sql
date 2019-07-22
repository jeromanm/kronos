create or replace procedure rol_usuario$aix(x$new rol_usuario%ROWTYPE) is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
    v$pdq number;
begin
    v$pdq := rol$propagar_vistas$100(x$new.id_rol, x$new.id_usuario, x$new.id_rol_usuario);
    v$pdq := rol$propagar_filtros$100(x$new.id_rol, x$new.id_usuario, x$new.id_rol_usuario);
    v$pdq := rol$propagar_favoritos$100(x$new.id_rol, x$new.id_usuario, x$new.id_rol_usuario);
    update usuario set es_usuario_modificado = v$true where id_usuario = x$new.id_usuario;
end;
/
show errors
