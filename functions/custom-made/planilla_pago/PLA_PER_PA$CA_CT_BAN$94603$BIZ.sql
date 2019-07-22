create or replace function pla_per_pa$ca_ct_ban$94603$biz(x$super number, x$solicitud number) return number is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg           nvarchar2(200);
  x$user            varchar2(30);
  contador          number:=0;
  v$nen_codigo      number;
  v$ent_codigo      number;
  v_baja_id         number;
  v_estado          number;
  v_ano             number;
begin --anular solicitud de cuenta
  Begin 
    Select ESTADO_SOLICITUD, to_char(fecha_solicitud,'yyyy')
      into v_estado, v_ano
    From encabezado_solicitud 
    Where id=x$solicitud And tipo_alta='true';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_estado:=0;
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el estado de la solicitud de cuenta, mensaje:' || err_msg, true);
  End;
  if v_estado<>1 then
    raise_application_error(v$err, 'Error: ls solicitud de cuenta no está en estado solicitado, o no existe.', true);
  end if;
  begin
    Update encabezado_solicitud set estado_solicitud=3 where id=x$solicitud;
  exception
  when others then
    raise_application_error(v$err, 'Error al intentar crear la solicitud de baja de la cuenta banco, mensaje:' || sqlerrm, true);
  end;
  return 0;
exception
when others then
   raise_application_error(v$err, 'Error en el procedimiento Cancelar Cuenta:'|| sqlerrm);
end;
/
