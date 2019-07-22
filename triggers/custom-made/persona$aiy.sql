create or replace procedure persona$aiy(x$row persona%ROWTYPE)
is
begin
    asociar_persona_auxiliares(x$row.id, x$row.codigo);
end;
/
