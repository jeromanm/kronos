create or replace function lote$inactivar$biz(x$super         number,
                                              x$lote          number,
                                              x$observaciones nvarchar2)
  return number is
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid raw(8);
  v$log rastro_proceso_temporal%ROWTYPE;

  err_num NUMBER;
  err_msg VARCHAR2(255);
begin

  for reg in (select lp.pension
                from lote l, lote_pension lp
               where l.id = lp.lote
                 and l.id = x$lote and EXCLUIR='false') loop

    update pension
       set observaciones_inactivar = x$observaciones,
           activa                  = 'false',
           fecha_inactivar         = current_date,
           usuario_inactivar       = current_user_id()
     where id = reg.pension;

  end loop;

  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'),
                         'lote',
                         'id',
                         x$lote);
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
