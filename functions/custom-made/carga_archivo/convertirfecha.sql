create or replace function convertirfecha(x$fecha varchar2) return date is
  v$err       constant number := -20000; -- an integer in the range -20000..-20999
  v$fecha     varchar2(30);
begin
  if x$fecha is null then
    return to_date('01-JAN-1900');
  else
    begin
      Select to_date(x$fecha,'dd/mm/yyyy') into v$fecha From dual;
    exception
    when others then
      return to_date('01-JAN-1900');
    end;
    return v$fecha;
  end if;
exception
	when others then
		raise_application_error(v$err, 'Error al transformar fecha, mensaje:'|| sqlerrm, true);
end;
/
