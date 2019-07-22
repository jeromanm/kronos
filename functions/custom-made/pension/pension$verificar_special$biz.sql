create or replace function pension$verificar_special$biz(x$super number, x$pension number, x$especial varchar2) return number is
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$especial    varchar2(5);
  v$aux         number;
  -- elegibilidad especial
begin
  if x$especial is null then
    v$especial:='false';
  else
    v$especial:=x$especial;
  end if;
  v$aux:= pension$verificar$biz(x$super, x$pension, v$especial);
  return 0;
EXCEPTION
  WHEN OTHERS THEN
		v$msg := SQLERRM;
		raise_application_error(v$err, 'Error en elegibilidad esepcial, mensaje:'|| v$msg, true);  
end;
/
