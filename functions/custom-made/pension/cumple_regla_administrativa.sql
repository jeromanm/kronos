create or replace procedure cumple_regla_administrativa(x$pension number, x$cantidad IN OUT integer, x$observacion IN OUT varchar2) as
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
BEGIN
  Select case when pn.regla_administrativa='true' then 1
         else 0 end
  into  x$cantidad
  From pension pn
  where pn.id=x$pension;
  if x$cantidad>0 then
    x$observacion:='Regla Administrativa Verdadero por Elegibilidad';
  end if;
EXCEPTION
WHEN OTHERS THEN
  v$msg := SQLERRM;
  raise_application_error(v$err, v$msg, true);
END;
/