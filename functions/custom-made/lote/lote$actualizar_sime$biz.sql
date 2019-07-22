create or replace function lote$actualizar_sime$biz(x$super         number,
                                                    x$lote          number,
                                                    x$numero_sime   nvarchar2,
                                                    x$observaciones nvarchar2)
  return number is
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid         raw(8);
  v$log         rastro_proceso_temporal%ROWTYPE;
  v_numero_sime varchar(12);
  err_num       NUMBER;
  err_msg       VARCHAR2(255);
begin
  update lote
     set numero_sime = x$numero_sime, observaciones = x$observaciones
  where id = x$lote;

  for reg in (select b.pension
                from lote a, lote_pension b
               where a.id = b.lote
                 and b.lote = x$lote and EXCLUIR='false') loop
    update pension set numero_sime = x$numero_sime where id = reg.pension;
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
    raise_application_error(v$err, err_msg, true);
end;
/
