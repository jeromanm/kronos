create or replace function grupo_proceso$cancelar$biz(x$super number, x$grupo_proceso number) return number is
begin
    return grupo_proceso$unlock(x$grupo_proceso);
end;
/
show errors
