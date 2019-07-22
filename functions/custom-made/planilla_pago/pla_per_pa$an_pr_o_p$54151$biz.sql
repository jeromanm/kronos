create or replace function pla_per_pa$an_pr_o_p$54151$biz(x$super number, x$orden_pago number) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               nvarchar2(200);
  x$ano                 integer;
  x$mes                 integer;
  v$id_orden_pago       number;
  v$estado_orden_pago   number;
begin
  begin
    Select a.id, a.estado, a.mes, a.ano
      into v$id_orden_pago, v$estado_orden_pago, x$mes, x$ano
    From orden_pago a 
    Where a.id=x$orden_pago;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos de la orden de pago solicitada.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor de la orden de pago, mensaje:' || err_msg, true);
  end;
  if v$estado_orden_pago<>1 then
    raise_application_error(v$err, 'Error: no puede modificar la orden de pago en el estado actual.',true);
  end if;
  begin
    Update orden_pago set estado=3, numero_solicitud=null, fecha_transicion=sysdate, usuario=CURRENT_USER_ID 
    Where id=v$id_orden_pago;
    Update resumen_pago_pension set detalle_orden_pago=null Where id in (Select resumen_pago_pension From detalle_orden_pago Where orden_pago =v$id_orden_pago);
    Update detalle_orden_pago set resumen_pago_pension = null Where orden_pago =v$id_orden_pago;
  exception
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar anular la orden de pago, mensaje:' || err_msg, true);
  end;
  return 0;
exception
when others then
  raise_application_error(v$err, 'Error en el procedimiento asociar STR a orden  de pago:'|| sqlerrm);
end;
/
