create or replace function pension$finalizar$biz(x$super number, x$pension number, x$causa number, x$otras_causas nvarchar2, x$observaciones nvarchar2)
  return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log rastro_proceso_temporal%ROWTYPE;
  v$inserta_transicion  number;
  v$estado_inicial      number;
  v$estado_final        number;
  err_num               NUMBER;
  err_msg               VARCHAR2(255);
begin
  v$estado_inicial := pension$estado$inicial$biz(x$pension);
  if v$estado_inicial<>1 And v$estado_inicial<>3 And v$estado_inicial<>7 then
    raise_application_error(v$err, 'Error: la pensión ' || x$pension || ', está en estado diferente a solicitada, acreditada y/o otorgada.', true);
  end if;
  v$estado_final   := 10;
  update pension set causa_finalizar = x$causa, otras_causas_finalizar = x$otras_causas,
                     observaciones = x$observaciones, estado = v$estado_final, fecha_transicion = current_date,
                     usuario_transicion = current_user_id(), activa = 'false'
  where id = x$pension;
  v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null,
                                                 x$observaciones, null, null, null, null, null, null);
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/
