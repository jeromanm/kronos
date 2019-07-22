create or replace procedure rol_funcion$aix(x$new rol_funcion%ROWTYPE) is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
begin
    if (x$new.version_rol_funcion >= 0) then
        insert into rol_funcion_par (id_rol_funcion_par, id_rol_funcion, id_funcion_parametro)
        select util.bigintid(), x$new.id_rol_funcion, id_funcion_parametro
        from funcion_parametro
        where id_funcion = x$new.id_funcion
        and acceso_restringido = v$true
        order by 1;
    end if;
    update usuario set es_usuario_modificado = v$true where id_usuario in (
    select id_usuario from rol_usuario where id_rol = x$new.id_rol);
end;
/
show errors
