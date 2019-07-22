create or replace procedure ficha_persona$aiy(x$row ficha_persona%ROWTYPE)
is
  v_variable_global     varchar2(20);
begin --modificado SIAU 11885
  if x$row.version_ficha_hogar is null then
    begin
      Select valor into v_variable_global From variable_global where numero=103;
    exception
    when no_data_found THEN
      raise_application_error(-20001,'Error: no se encuentran valores de la variable global 103 (version ficha hogar)', true);
    when others then
      raise_application_error(-20001,'Error: al intentar obtener el valor de la versión de ficha hogar, mensaje:'|| sqlerrm, true);
    end;
  else
    v_variable_global:=x$row.version_ficha_hogar;
  end if;
  if x$row.version=1 then
    begin
      insert into respuesta_ficha_persona (id, version, ficha, pregunta)
        Select busca_clave_id, 0, x$row.id, id
        From pregunta_ficha_persona Where VERSION_FICHA=v_variable_global;
    exception
    when others then
      raise_application_error(-20001,'Error: al intentar crear las respuestas en blanco para la ficha persona, mensaje:'|| sqlerrm, true);
    end;
  end if;
end;
/
