create or replace procedure clase_pension$aiy(x$row clase_pension%ROWTYPE)
is
begin
  Insert Into clase_pension_comp (id, version, codigo, clase, clase_comp, compatible, restringido, observaciones)
    Select busca_clave_id, 0, busca_clave_id, x$row.id, id, 'false', 'false', null
    From clase_pension;
end;
/
