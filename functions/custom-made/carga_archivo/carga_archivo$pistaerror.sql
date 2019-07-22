create or replace function carga_archivo$pistaerror(x$archivo_linea_id NUMBER, observaciones nvarchar2) return number is
   x$id 	number;
Begin
  	x$id:=busca_clave_id;
	INSERT INTO ERROR_ARCHIVO (ID, VERSION, CODIGO, LINEA, TIPO, DESCRIPCION)
	VALUES (x$id, 0, x$id, x$archivo_linea_id, 1, observaciones);
   return 0;
exception
  when others then
    raise_application_error(-20100, SQLERRM, true);
end;
/
