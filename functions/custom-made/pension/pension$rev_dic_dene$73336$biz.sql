create or replace function pension$rev_dic_dene$73336$biz(x$super number, x$pension number, x$observaciones nvarchar2)
  return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               VARCHAR2(255);
  v$inserta_transicion  number;
  v$estado_inicial      number;
  v$estado_final        number;
begin
  v$estado_inicial := pension$estado$inicial$biz(x$pension);
  v$estado_final   := 3;
  update pension set dictamen_denegar=null, fecha_dictamen_denegar = null, antecedente_dene = null, disposicion_dene_uno = null,
                     disposicion_dene_dos = null, disposicion_dene_tres = null, opinion_dene_uno = null, opinion_dene_dos = null,
                     opinion_dene_tres = null, causa_denegar = null, otras_causas_denegar = null, observaciones = x$observaciones, 
                     estado = v$estado_final, fecha_transicion   = current_date, usuario_transicion = current_user_id(), resumen_dictamen_denegar=null
  where id = x$pension;
  v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, x$observaciones,
                                                 null, null, null, null, null, null);
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id',x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(v$err, err_msg, true);
end;
/