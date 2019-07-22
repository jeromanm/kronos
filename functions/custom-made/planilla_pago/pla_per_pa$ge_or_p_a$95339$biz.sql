create or replace function pla_per_pa$ge_or_p_a$95339$biz(x$super number, x$orden_pago number) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               nvarchar2(200);
  v$estado_orden_pago   number;
begin
  begin
    Select a.estado into v$estado_orden_pago
    From orden_pago a 
    Where a.id=x$orden_pago And a.cuenta<>'true';
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos de la orden de pago administrativa solicitada.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor de la orden de pago, mensaje:' || err_msg, true);
  end;
  if v$estado_orden_pago<>1 then
    raise_application_error(v$err, 'Error: no puede modificar la orden de pago en el estado actual.',true);
  end if;
  begin
    Update orden_pago set estado=2, fecha_transicion=sysdate, usuario=CURRENT_USER_ID 
    Where id=x$orden_pago;
  exception
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar actualizar el estado de la orden de pago administrativa, mensaje:' || err_msg, true);
  end;
  return 0;
exception
when others then
  raise_application_error(v$err, 'Error en el procedimiento procesar orden de pago administrativa, mensaje:'|| sqlerrm);
end;
/
