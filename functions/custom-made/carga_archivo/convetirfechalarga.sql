create or replace function convertirfechalarga(x$fecha date) return varchar2 is
  v$err       constant number := -20000; -- an integer in the range -20000..-20999
  v$fecha     varchar2(30);
begin
  Select to_char(x$fecha,'dd') || ' de ' || 
        case to_char(x$fecha,'mm') when '01' then 'Enero' when '02' then 'Febrero' when '03' then 'Marzo' when '04' then 'Abril' when '05' then 'Mayo' when '06' then  'Junio' 
         when '07' then 'Julio' when '08' then 'Agosto' when '09' then 'Setiembre' when '10' Then 'Octubre' when '11' then 'Noviembre' when '12' then 'Diciembre' else 'N/E'  end 
        || ' de ' || to_char(x$fecha,'yyyy')
    into v$fecha
  From dual;
  return v$fecha;
exception
	when others then
		raise_application_error(v$err, 'Error al transformar fecha, mensaje:'|| sqlerrm, true);
end;
/
