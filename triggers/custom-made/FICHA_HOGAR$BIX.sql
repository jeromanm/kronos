create or replace function ficha_hogar$bix(x$new in out ficha_hogar%ROWTYPE)
return ficha_hogar%ROWTYPE is
v_variable_global   nvarchar2(20);
begin --modificado SIAU 11885
  if x$new.version_ficha_hogar is null then
    begin
      Select valor into v_variable_global From variable_global where numero=103;
    exception
    when no_data_found THEN
      raise_application_error(-20001,'Error: no se encuentran valores de la variable global 103 (version ficha hogar)', true);
    when others then
      raise_application_error(-20001,'Error: al intentar obtener el valor de la versión de ficha hogar, mensaje:'|| sqlerrm, true);
    end;
    x$new.version_ficha_hogar:=v_variable_global;
  end if;
  return x$new;
end;
/