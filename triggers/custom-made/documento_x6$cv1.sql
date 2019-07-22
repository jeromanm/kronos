create or replace function documento_x6$cv1(x$row documento%ROWTYPE) return documento%ROWTYPE is
    v$row documento%ROWTYPE;
begin
    v$row := x$row;
--  raise notice 'documento_x6$cv1(%)', x$row;
    v$row.descripcion := upper(v$row.descripcion);
    --v$row.archivo := upper(v$row.archivo);
    v$row.observaciones := upper(v$row.observaciones);
    return v$row;
end;