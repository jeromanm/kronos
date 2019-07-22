create or replace function lote$reve_dict_deneg$43008$biz(x$super number, x$lote number, x$observaciones nvarchar2)
  return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$inserta_transicion  number;
  v$estado_inicial      number;
  v$estado_final        number;
  err_num               NUMBER;
  err_msg               VARCHAR2(255);
begin
  For reg in (Select lp.pension
              From lote l, lote_pension lp, pension pn
              Where l.id = lp.lote
                And lp.pension = pn.id
                And l.id = x$lote And pn.estado=8) loop
    v$estado_inicial := pension$estado$inicial$biz(reg.pension);
    Select estado_final into  v$estado_final
    From transicion_pension where pension=reg.pension 
      And fecha=(Select max(fecha) From transicion_pension tp2 where tp2.pension=reg.pension) 
      And rownum=1;
    Update pension set observaciones = x$observaciones, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = current_user_id(),
                       antecedente_dene = null, disposicion_dene_uno = null, disposicion_dene_dos = null,
                       disposicion_dene_tres = null, opinion_dene_uno =  null, opinion_dene_dos = null, dictamen_denegar = null,
                       opinion_dene_tres = null, causa_denegar = null, otras_causas_denegar = null, fecha_dictamen_denegar = null
    Where id = reg.pension;
    v$inserta_transicion := transicion_pension$biz(reg.pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, x$observaciones,
                                                   null, null, null, null, null, null);
  End loop;
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'lote', 'id', x$lote);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(v$err, err_msg, true);
end;
/