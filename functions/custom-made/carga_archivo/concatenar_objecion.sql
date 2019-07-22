create or replace function concatenar_objecion(x$pension number, x$tipo number, x$estado varchar2)return varchar2 is
  v$err         constant number := -20000;
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$cadena      varchar2(4000):='';
  err_num       NUMBER;
  err_msg       VARCHAR2(255);
BEGIN
  For reg in (Select comentarios, observaciones
              From objecion_pension 
              Where pension=x$pension And objecion_invalida=x$estado) 
  loop
    if x$tipo=1 then
      v$cadena:= v$cadena || reg.comentarios || ', ';
    elsif x$tipo=2 then
      v$cadena:= v$cadena || reg.observaciones || ', ';
    end if;
	end loop;
  v$cadena:=substr(v$cadena,1,length(v$cadena)-2);
  return v$cadena;
EXCEPTION
  WHEN OTHERS THEN
    v$msg := SQLERRM;
    raise_application_error(v$err, v$msg, true);
END;
/
