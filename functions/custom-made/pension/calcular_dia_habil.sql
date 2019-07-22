create or replace FUNCTION calcular_dia_habil(x$fechadesde date, x$fechahasta date) RETURN integer AS
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$cantidad    integer:=0;
  v$feriado     integer:=0;
  v$fechadesde  date:=x$fechadesde;
BEGIN
  while v$fechadesde < x$fechahasta loop
    begin
      Select Count(id) into v$feriado From dia_feriado where to_char(fecha,'dd/mm/yyyy')=to_char(v$fechadesde,'dd/mm/yyyy');
    exception
    when others then
      v$msg := SQLERRM;
      raise_application_error(v$err,'Error al intentar obtener el día feriado, mensaje:' || v$msg,true);
    end;
    if to_char(v$fechadesde,'D')<>1 And to_char(v$fechadesde,'D')<>7 And v$feriado=0 then --no es domingo ni sabado
      v$cantidad:=v$cantidad+1;
    end if;
    v$fechadesde:=v$fechadesde+1;
  end loop;
   return v$cantidad;
EXCEPTION
WHEN OTHERS THEN
  v$msg := SQLERRM;
  raise_application_error(v$err, v$msg, true);
END;
/