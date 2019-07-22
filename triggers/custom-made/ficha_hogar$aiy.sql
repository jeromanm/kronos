create or replace procedure ficha_hogar$aiy(x$row ficha_hogar%ROWTYPE)
is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$variable_global varchar2(30);
begin --modificado SIAU 11885
    if x$row.version=1 then
      if x$row.version_ficha_hogar is null then
        begin
          Select valor into v$variable_global From variable_global where numero=103;
        exception
        when no_data_found then
          raise_application_error(v$err,'Error: no se pudo obtener/actualizar la version de la ficha hogar.',true);
        when others then
          v$msg := SQLERRM;
          raise_application_error(v$err,'Error al intentar actualizar la versión de la ficha hogar, mensaje:' || v$msg,true);
        end;
      else
        v$variable_global:=x$row.version_ficha_hogar;
      end if;
      begin
        insert into respuesta_ficha_hogar (id, version, ficha, pregunta)
        Select busca_clave_id, 0, x$row.id, id
          From pregunta_ficha_hogar Where VERSION_FICHA=v$variable_global;
      exception
      when others then
        v$msg := SQLERRM;
        raise_application_error(v$err,'Error al intentar crear las respuestas de ficha hogar, mensaje:' || v$msg,true);
      end;
    end if;
end;
/
