create or replace function linea_archivo$cv1(x$row linea_archivo%ROWTYPE) return linea_archivo%ROWTYPE is
    v$row linea_archivo%ROWTYPE;
begin
    v$row := x$row;
--  raise notice 'linea_archivo$cv1(%)', x$row;
    --v$row.texto := upper(v$row.texto);
    return v$row;
end;