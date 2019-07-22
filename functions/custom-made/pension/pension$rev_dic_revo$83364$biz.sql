create or replace function pension$rev_dic_revo$83364$biz(x$super number, x$pension number, x$observaciones nvarchar2)
  return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               VARCHAR2(255);
  v$inserta_transicion  number;
  v$estado_inicial      number;
  v$estado_final        number;
begin -- revertir dictamen revocar
  v$estado_inicial := pension$estado$inicial$biz(x$pension);
  v$estado_final   := 7;
  Update pension set observaciones = x$observaciones, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = current_user_id(),
                     fecha_dictamen_revocar=null, dictamen_revocar=null,  resumen_dictamen_revocar = null,
                     antecedente_revo = null, disposicion_revo_uno = null, disposicion_revo_dos = null, disposicion_revo_tres = null,
                     opinion_revo_uno =  null, opinion_revo_dos  = null, opinion_revo_tres =  null, causa_revocar = null, otras_causas_revocar = null
  Where id = x$pension;
  v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, x$observaciones,
                                                 null, null, null, null, null, null);
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(v$err, err_msg, true);
end;
/