create or replace function persona$anular_no_indigena$biz(x$super number, x$persona number, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
--  v$log rastro_proceso_temporal%ROWTYPE;
    v$cedula    varchar2(20);
begin --  Persona.anularNoIndigena - business logic
  begin
    Select codigo into v$cedula From persona Where id=x$persona;
    Update persona set OBSERVACIONES_ANULAR_NO_INDIG=null, NOMBRE_ENTIDAD=null, NUMERO_SIME=null 
    Where id = x$persona;
    Delete From no_indigena Where cedula=v$cedula;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
  exception
  WHEN NO_DATA_FOUND THEN
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
    raise_application_error(v$err, v$msg, true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err, 'Error al intentar anular los registros de no indigena para la persona:' || v$cedula || ', mensaje:' || v$msg, true);
  end;
end;
/