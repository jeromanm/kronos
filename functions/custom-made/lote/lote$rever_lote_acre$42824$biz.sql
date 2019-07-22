create or replace function lote$rever_lote_acre$42824$biz(x$super number, x$lote number, x$observaciones nvarchar2) return number is
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid raw(8);
  v$log rastro_proceso_temporal%ROWTYPE;
  v$inserta_transicion number;
  v$estado_inicial     number;
  v$estado_final       number;
  err_num              NUMBER;
  err_msg              VARCHAR2(255);
begin
  for reg in (select lp.pension
               From lote l, lote_pension lp
               Where l.id = lp.lote
                 and l.id = x$lote) loop
		v$estado_inicial := pension$estado$inicial$biz(reg.pension);
		v$estado_final   := 1;
		update pension set observaciones      = 'hecho desde lote$revertir_acreditar$biz, ' || x$observaciones,
           estado = 1, fecha_transicion = current_date,
           usuario_transicion = current_user_id(), activa = 'false'
		where id = reg.pension;
		v$inserta_transicion := transicion_pension$biz(reg.pension, current_date, current_user_id(), v$estado_inicial,
                                                   v$estado_final, null, null, x$observaciones, null, null, null, null,
                                                   null, null);
  end loop;
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'),'lote','id',x$lote);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(-20001, err_msg, true);
end;
/
