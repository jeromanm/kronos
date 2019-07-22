create or replace function persona$act_dat_cedu$43119$biz(x$super number, x$persona number, x$cedula number, x$fecha_expedicion_cedula date, x$fecha_vencimiento_cedula date, 
                                                          x$carnet_militar nvarchar2, x$pariente number, x$parentesco number) return number is
    v$err         constant number := -20000; -- an integer in the range -20000..-20999
    err_msg       nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$paraguayo   varchar2(5):='true';
    v$sexo        number;
    v$fech_nacim  date;
begin --Persona.actualizarDatosCedula - business logic
  begin  
    Select case nacionalidad when 226 then 'true' else 'false' end, sexo, fech_nacim 
      into v$paraguayo, v$sexo, v$fech_nacim 
    From cedula where id=x$cedula;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v$paraguayo:='false';
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 2000);
    raise_application_error(v$err, 'Error al intentar obtener los datos de identificación de la persona, mensaje:' || err_msg, true);
  END;
  update persona set cedula = x$cedula, fecha_expedicion_cedula = x$fecha_expedicion_cedula, fecha_vencimiento_cedula = x$fecha_vencimiento_cedula, carnet_militar = x$carnet_militar, 
                     pariente = x$pariente, parentesco = x$parentesco, paraguayo= v$paraguayo, sexo=v$sexo, fecha_nacimiento=v$fech_nacim
  where id = x$persona;
  if not SQL%FOUND then
      err_msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
      raise_application_error(v$err, err_msg, true);
  end if;
  return 0;
EXCEPTION
when others then
  err_msg := SUBSTR(SQLERRM, 1, 2000);
  raise_application_error(v$err, 'Error al intentar actualizar los datos de la persona, mensaje:' || err_msg, true);
end;
/