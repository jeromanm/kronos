create or replace procedure cumple_plazo(x$pension number, x$cantidad IN OUT integer, x$observacion IN OUT varchar2) as
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
BEGIN
  Select case when rp.FECHA_TRANSICION is null then 0
         else calcular_dia_habil(pn.FECHA_NOTIFICACION,rp.FECHA_TRANSICION) end 
  into  x$cantidad
  From pension pn left outer join reclamo_pension rp on pn.id = rp.pension And rp.estado=1 And rp.tipo=1
  where pn.id=x$pension;
  if x$cantidad>0 then
    x$observacion:='Días hábiles transcurridos:' || x$cantidad;
  end if;
EXCEPTION
WHEN OTHERS THEN
  v$msg := SQLERRM;
  raise_application_error(v$err, v$msg, true);
END;
/