create or replace function grupo_proceso$unlock(grupo number) return number is
begin
    update  grupo_proceso
    set     id_rastro_proceso = null,
            numero_condicion_eje_fun = null
    where   id_grupo_proceso = grupo;
    /**/
    return 0;
end;
/
show errors
