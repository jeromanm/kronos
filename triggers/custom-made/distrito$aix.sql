create or replace procedure distrito$aix(x$new distrito%ROWTYPE)
is 
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
  begin
    Insert Into segmento_pension (id, version, codigo, nombre, grupo, distrito)
      Select busca_clave_id, 0, 'S' || gp.codigo || x$new.codigo, gp.nombre || ':' || x$new.nombre, gp.id, x$new.id 
      From grupo_pension gp;
  EXCEPTION
  WHEN OTHERS THEN
		v$msg := SQLERRM;
		raise_application_error(v$err, 'Error al intentar insertar los segmentos pensión, mensaje:'|| v$msg, true);  
  end;
end;
/