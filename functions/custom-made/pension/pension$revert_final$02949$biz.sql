create or replace function pension$revert_final$02949$biz(x$super number, x$pension number, x$observaciones nvarchar2) return number is

  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid raw(8);
  v$log rastro_proceso_temporal%ROWTYPE;

  v$inserta_transicion number;
  v$estado_inicial     number;
  v$estado_final       number;
  -- revertir finalizar
  err_num NUMBER;
  err_msg VARCHAR2(255);
begin

  v$estado_inicial := pension$estado$inicial$biz(x$pension);
  v$estado_final   := 7;

  update pension
     set causa_finalizar        = null,
         otras_causas_finalizar = null,
         observaciones          = x$observaciones,
         estado                 = 7,
         fecha_transicion       = current_date,
         usuario_transicion     = current_user_id(),
         activa                 = 'false'
   where id = x$pension;

  v$inserta_transicion := transicion_pension$biz(x$pension,
                                                 current_date,
                                                 current_user_id(),
                                                 v$estado_inicial,
                                                 v$estado_final,
                                                 null,
                                                 null,
                                                 x$observaciones,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null);

  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'),
                         'pensión',
                         'id',
                         x$pension);
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

