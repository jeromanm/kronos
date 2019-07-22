create or replace function usuario$av2(x$new usuario%ROWTYPE, x$old usuario%ROWTYPE)
return usuario%ROWTYPE is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
    v$new usuario%ROWTYPE;
begin
    v$new := x$new;
    if (x$old.es_super_usuario <> v$new.es_super_usuario) then
        v$new.es_usuario_modificado := v$true;
    end if;
    return v$new;
end;
/
show errors
